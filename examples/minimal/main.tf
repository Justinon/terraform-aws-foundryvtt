module "foundry_server_minimal_example" {
  source = "git@github.com:Justinon/terraform-aws-foundryvtt.git"

  aws_account_id          = var.aws_account_id
  aws_automation_role_arn = var.aws_automation_role_arn
  foundry_password        = var.foundry_password
  foundry_username        = var.foundry_username
}

output endpoint {
  value = module.foundry_server.lb_dns_name
}
