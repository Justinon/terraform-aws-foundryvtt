# data "aws_iam_policy_document" "ecs_service_assume_role" {
#   statement {
#     sid     = "ECSServiceAccess"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ecs.amazonaws.com"]
#     }
#   }
# }

data "aws_iam_policy" "amazon_ecs_service_role" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
}

resource "aws_iam_service_linked_role" "ecs_service" {
  aws_service_name = "ecs.amazonaws.com"
  description      = "Starts with the requirements for the ecs service to function."
  name_suffix      = "foundry-ecs-service-${terraform.workspace}"
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = aws_iam_service_linked_role.ecs_service.name
  policy_arn = data.aws_iam_policy.amazon_ecs_service_role.arn
}
