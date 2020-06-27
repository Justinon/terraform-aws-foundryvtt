data "aws_iam_policy_document" "foundry_server_kms_key" {
  statement {
    sid = "RestrictFoundryCredentialsAdminAccess"
    actions = [
      "kms:CancelKeyDeletion",
      "kms:Create*",
      "kms:Delete*",
      "kms:Describe*",
      "kms:Disable*",
      "kms:Enable*",
      "kms:Get*",
      "kms:List*",
      "kms:Put*",
      "kms:Revoke*",
      "kms:ScheduleKeyDeletion",
      "kms:Update*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
  }

  statement {
    sid = "RestrictFoundryCredentialsAccess"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.foundry_server.arn,
        var.aws_automation_role_arn
      ]
    }
  }
}

resource "aws_kms_key" "foundry_server_credentials" {
  deletion_window_in_days = 7 # Lowest possibe
  description             = "Used exclusively by the foundry server to read credentials for foundry tool configuration."
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.foundry_server_kms_key.json
  tags                    = local.tags_rendered
}

resource "aws_ssm_parameter" "foundry_username" {
  description = "Used exclusively by the foundry server to configure the foundry tool."
  key_id      = aws_kms_key.foundry_server_credentials.arn
  name        = "/foundryvtt-terraform/${terraform.workspace}/username"
  tags        = local.tags_rendered
  type        = "SecureString"
  value       = var.foundry_username
}

resource "aws_ssm_parameter" "foundry_password" {
  description = "Used exclusively by the foundry server to configure the foundry tool."
  key_id      = aws_kms_key.foundry_server_credentials.arn
  name        = "/foundryvtt-terraform/${terraform.workspace}/password"
  tags        = local.tags_rendered
  type        = "SecureString"
  value       = var.foundry_password
}

resource "aws_ssm_parameter" "foundry_admin_key" {
  count       = var.foundry_admin_key == "" ? 0 : 1
  description = "Used exclusively by the foundry server to configure the foundry tool."
  key_id      = aws_kms_key.foundry_server_credentials.arn
  name        = "/foundryvtt-terraform/${terraform.workspace}/admin_key"
  tags        = local.tags_rendered
  type        = "SecureString"
  value       = var.foundry_admin_key
}

output credentials_kms_key_arn {
  description = "The ARN of the KMS key used by the server to decrypt and encrypt Foundry credentials. Used exclusively to maintain consistency and legitimacy of the server and license respectively."
  value = aws_kms_key.foundry_server_credentials.arn
}

output credentials_kms_key_id {
  description = "The ID of the KMS key used by the server to decrypt and encrypt Foundry credentials. Used exclusively to maintain consistency and legitimacy of the server and license respectively."
  value = aws_kms_key.foundry_server_credentials.key_id
}