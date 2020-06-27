data "aws_iam_policy_document" "ecs_service_assume_role" {
  statement {
    sid     = "ECSServiceAccess"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "amazon_ecs_service_role" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
}

resource "aws_iam_role" "ecs_service" {
  assume_role_policy    = data.aws_iam_policy_document.foundry_server_assume_role.json
  description           = "Starts with the requirements for the ecs service to function."
  force_detach_policies = true
  name_prefix           = "foundry-ecs-service-${terraform.workspace}"
  tags                  = local.tags_rendered
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = data.aws_iam_policy.amazon_ecs_service_role.arn
}
