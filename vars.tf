locals {
  foundry_port              = 30000
  region                    = data.aws_region.current.name
  server_availability_zones = formatlist("${local.region}%s", ["a", "b"])

  tag_foundry = {
    key   = "purpose"
    value = "foundry-server"
  }
  tags = length(var.tags) == 0 ? list(local.tag_foundry) : list(local.tag_foundry, var.tags...)
  tags_rendered = {
    for tag in local.tags :
    tag.key => tag.value
  }
}

data "aws_region" "current" {}

variable artifacts_bucket_public {
  default     = true
  description = "Whether or not the artifacts bucket should be public. To reuse this bucket for direct Amazon S3 asset storage in browser, set to true."
}

variable artifacts_data_expiration_days {
  default     = 30
  description = "The amount of days after which non-current version of the artifacts bucket Foundry data is expired."
}

variable aws_account_id {
  description = "The root user of the AWS account provided will be the sole credentials KMS key administrator."
  type        = string
}

variable aws_automation_role_arn {
  description = "The automation role used by Terraform. Gets decrypt/encrypt access to KMS credentials key."
  type        = string
}

variable foundry_admin_key {
  default     = ""
  description = "The Admin Access Key to set for password-protecting administration access to the Foundry tool. Will be encrypted in AWS Parameter Store for exclusive use by the server."
  type        = string
}

variable foundry_password {
  description = "Will be encrypted in AWS Parameter Store for exclusive use by the server to securely obtain and use the Foundry license."
  type        = string
}

variable foundry_username {
  description = "Will be encrypted in AWS Parameter Store for exclusive use by the server to securely obtain and use the Foundry license."
  type        = string
}

variable foundryvtt_docker_image {
  default     = "felddy/foundryvtt:0.6.3"
  description = "Probably won't work with other images yet but the option is there if you want to experiment"
}

variable security_groups {
  default     = []
  description = "Any extra security groups to associate with the Foundry server."
}

variable tags {
  type = list(object({
    key   = string,
    value = string
  }))
  default     = []
  description = "Any additional AWS tags you want associated with all created and eligible resources."
}

variable vpc_cidr_block {
  default     = "20.0.0.0/22"
  description = "The CIDR block of the Foundry VPC housing all created and eligible resources."
  type        = string
}
