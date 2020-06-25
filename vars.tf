locals {
  foundry_tag = {
    key   = "purpose"
    value = "foundry-server"
  }
  tags = length(var.tags) == 0 ? list(local.foundry_tag) : list(local.foundry_tag, var.tags...)
  tags_rendered = {
    for tag in local.tags :
    tag.key => tag.value
  }

  server_availability_zones = formatlist("${var.region}%s", ["a", "b"])
}

variable artifacts_data_expiration_days {
  default     = 30
  description = "The amount of days after which non-current version of foundry data is expired."
}

variable aws_account_id {
  description = "The root user of the AWS account provided will be the sole credentials KMS key administrator."
  type        = string
}

variable aws_automation_role_arn {
  description = "The automation role used by Terraform to perform apply. Gets decrypt/encrypt access to KMS credentials key."
  type        = string
}

variable ebs_block_devices {
  default     = []
  description = "Should you want to mount any ebs block devices, such as for data storage, do so here."
  type = list(object({
    device_name = string
  }))
}

variable foundry_admin_key {
  default     = "none"
  description = "(Optional) Will be encrypted in AWS Parameter Store for exclusive use by the foundry server to configure the foundry tool."
  type        = string
}

variable foundry_artifacts_bucket_public {
  default     = false
  description = "Whether or not the artifacts bucket should be public. To reuse this bucket for direct Amazon S3 asset storage in browser, set to true."
}

variable foundry_password {
  description = "Will be encrypted in AWS Parameter Store for exclusive use by the foundry server to configure the foundry tool."
  type        = string
}

variable foundry_username {
  description = "Will be encrypted in AWS Parameter Store for exclusive use by the foundry server to configure the foundry tool."
  type        = string
}

variable foundryvtt_docker_image {
  default = "felddy/foundryvtt:latest"
}

variable home_ip_address {
  description = "The IP address of your home network, which is the only IP allowed to SSH to the foundry server instance."
  type        = string
}

variable instance_type {
  default     = "t2.micro"
  description = "Defaults to free tier eligible type."
}

variable key_name {
  default     = ""
  description = "The name of the key to use for SSH. Can and should easily be generated as a key-pair in the AWS console."
}

variable region {
  description = "The closest region to you, as to minimize latency."
  type        = string
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
  default = []
}

variable vpc_cidr_block {
  description = "The CIDR block for the VPC."
  default     = "20.0.0.0/16"
  type        = string
}