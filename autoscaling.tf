locals {
  architecture = "x86_64"
}

# Amazon Linux 2
data "aws_ami" "amzn_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*amzn2-ami-hvm-*-${local.architecture}*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "foundry_server_user_data" {
  template = "${file("${path.module}/user_data.template.sh")}"
  vars = {
    architecture             = local.architecture
    foundry_artifacts_bucket = aws_s3_bucket.foundry_artifacts.id
    foundry_docker_image     = var.foundryvtt_docker_image
    foundry_port             = local.foundry_port
    operating_system         = "Linux"
    region                   = var.region
    terraform_workspace      = terraform.workspace
  }
}

resource "aws_security_group" "foundry_server" {
  name_prefix            = "foundry-server-sg-${terraform.workspace}"
  revoke_rules_on_delete = true
  tags                   = local.tags_rendered
  vpc_id                 = aws_vpc.foundry.id
}

resource "aws_security_group_rule" "allow_ssh" {
  count = var.ssh_key_name == "" ? 0 : 1

  cidr_blocks       = ["${var.home_ip_address}/32"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.foundry_server.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "allow_foundry_port_ingress" {
  from_port                = local.foundry_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.foundry_server.id
  source_security_group_id = aws_security_group.foundry_load_balancer.id
  to_port                  = local.foundry_port
  type                     = "ingress"
}

resource "aws_security_group_rule" "allow_outbound" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.foundry_server.id
  to_port           = 65535
  type              = "egress"
}

resource "aws_launch_configuration" "foundry_server_config" {
  associate_public_ip_address = true
  ebs_optimized               = length(var.ebs_block_devices) > 0
  iam_instance_profile        = aws_iam_instance_profile.foundry_server.name
  image_id                    = data.aws_ami.amzn_linux.id
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  name_prefix                 = "foundry-server-config-${terraform.workspace}"
  user_data_base64            = base64encode(data.template_file.foundry_server_user_data.rendered)
  security_groups             = concat(list(aws_security_group.foundry_server.id), var.security_groups)

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      delete_on_termination = ebs_block_device.value["delete_on_termination"]
      device_name           = ebs_block_device.value["device_name"]
      encrypted             = ebs_block_device.value["encrypted"]
      iops                  = ebs_block_device.value["iops"]
      snapshot_id           = ebs_block_device.value["snapshot_id"]
      volume_size           = ebs_block_device.value["volume_size"]
      volume_type           = ebs_block_device.value["volume_type"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "foundry_server" {
  availability_zones   = local.server_availability_zones
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.foundry_server_config.name
  max_size             = 1
  min_size             = 0
  name_prefix          = "foundry-server-asg-${terraform.workspace}"
  vpc_zone_identifier  = local.subnet_public_ids

  target_group_arns = [
    aws_lb_target_group.lb_foundry_server_http.arn,
    aws_lb_target_group.lb_foundry_server_https.arn,
  ]

  tag {
    key                 = "Name"
    value               = "foundry-server-${terraform.workspace}"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity
    ]
  }
}

output asg_arn {
  description = "The ARN of the autoscaling group serving the Foundry instance."
  value       = aws_autoscaling_group.foundry_server.arn
}

output asg_azs {
  description = "The availability zones in which the autoscaling group serves the Foundry instance."
  value       = aws_autoscaling_group.foundry_server.availability_zones
}

output asg_id {
  description = "The ID of the autoscaling group serving the Foundry instance."
  value       = aws_autoscaling_group.foundry_server.id
}

output launch_configuration_arn {
  description = "The ARN of the Foundry instance's launch configuration."
  value       = aws_launch_configuration.foundry_server_config.arn
}

output launch_configuration_id {
  description = "The ID of the Foundry instance's launch configuration."
  value       = aws_launch_configuration.foundry_server_config.id
}

output launch_configuration_name {
  description = "The name of the Foundry instance's launch configuration."
  value       = aws_launch_configuration.foundry_server_config.name
}
