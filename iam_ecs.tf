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

# data "aws_iam_policy" "amazon_ecs_service_role" {
#   arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
# }

# resource "aws_iam_service_linked_role" "ecs" {
#     aws_service_name = "ecs.amazonaws.com"
#     description = "Contains the elementary requirements for the ECS service to operate."
# }

# resource "aws_iam_role_policy_attachment" "ecs_service" {
#   role       = "AWSServiceRoleForECS"
#   policy_arn = data.aws_iam_policy.amazon_ecs_service_role.arn
#   depends_on = [aws_ecs_cluster.foundry_server]
# }
