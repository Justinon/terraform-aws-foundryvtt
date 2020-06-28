locals {
  ecs_secrets_foundry_admin_key = length(aws_ssm_parameter.foundry_admin_key) > 0 ? {
    name      = "FOUNDRY_ADMIN_KEY"
    valueFrom = element(aws_ssm_parameter.foundry_admin_key.*.arn, 0)
  } : null

  ecs_container_definition_foundry_server = [{
    image = var.foundryvtt_docker_image
    name  = "foundry-server-${terraform.workspace}"
    mountPoints = [{
      containerPath = "/data/Data"
      sourceVolume  = "foundry-data"
    }]
    portMappings = [{
      hostPort      = local.foundry_port
      protocol      = "tcp"
      containerPort = local.foundry_port
    }]
    secrets = [
      {
        name      = "FOUNDRY_USERNAME"
        valueFrom = aws_ssm_parameter.foundry_username.arn
      },
      {
        name      = "FOUNDRY_PASSWORD"
        valueFrom = aws_ssm_parameter.foundry_password.arn
      },
      local.ecs_secrets_foundry_admin_key
    ]
  }]

  ecs_container_availability_zones_stringified = format("[%s]", join(", ", local.server_availability_zones))
  ecs_container_foundry_user_and_group_id      = 421
}

resource "aws_ecs_cluster" "foundry_server" {
  name               = "foundry-server-${terraform.workspace}"
  capacity_providers = ["FARGATE"]
  tags               = local.tags_rendered

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "foundry_server" {
  cluster                           = aws_ecs_cluster.foundry_server.id
  desired_count                     = 1
  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = 120
  launch_type                       = "FARGATE"
  name                              = "foundry-server-${terraform.workspace}"
  propagate_tags                    = "TASK_DEFINITION"
  tags                              = local.tags_rendered
  task_definition                   = aws_ecs_task_definition.foundry_server.arn

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_foundry_server_http.arn
    container_name   = "foundry-server-${terraform.workspace}"
    container_port   = local.foundry_port
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${local.ecs_container_availability_zones_stringified}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_ecs_task_definition" "foundry_server" {
  cpu                      = 1024
  container_definitions    = jsonencode(local.ecs_container_definition_foundry_server)
  execution_role_arn       = aws_iam_role.foundry_server.arn
  family                   = "foundry-server-${terraform.workspace}"
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = local.tags_rendered
  task_role_arn            = aws_iam_role.foundry_server.arn

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.foundry_server.id]
    subnets          = local.subnets_public_ids
  }

  volume {
    name = "foundry-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.foundry_server_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.foundry_server_data.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_efs_file_system" "foundry_server_data" {
  creation_token = "foundry-server-data-${terraform.workspace}"
  encrypted      = true
  tags           = local.tags_rendered

  lifecycle_policy {
    transition_to_ia = "AFTER_${var.artifacts_data_expiration_days}_DAYS"
  }
}

data "aws_iam_policy_document" "foundry_data_efs" {
  statement {
    sid     = "FoundryServerMountAccess"
    actions = ["elasticfilesystem:ClientMount"]
    principals {
      type        = "AWS"
      identifiers = [aws_ecs_task_definition.foundry_server.task_role_arn]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }

  statement {
    sid     = "FoundryServerWriteAccess"
    actions = ["elasticfilesystem:ClientWrite"]
    principals {
      type        = "AWS"
      identifiers = [aws_ecs_task_definition.foundry_server.task_role_arn]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values   = [aws_efs_access_point.foundry_server_data.arn]
    }
  }
}

resource "aws_efs_file_system_policy" "foundry_server_data" {
  file_system_id = aws_efs_file_system.foundry_server_data.id
  policy         = data.aws_iam_policy_document.foundry_data_efs.json
}

resource "aws_efs_access_point" "foundry_server_data" {
  file_system_id = aws_efs_file_system.foundry_server_data.id
  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = local.ecs_container_foundry_user_and_group_id
      owner_uid   = local.ecs_container_foundry_user_and_group_id
      permissions = "660"
    }
  }
  posix_user {
    gid = local.ecs_container_foundry_user_and_group_id
    uid = local.ecs_container_foundry_user_and_group_id
  }
}
