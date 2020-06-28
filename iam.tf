data "aws_iam_policy_document" "foundry_server_assume_role" {
  statement {
    sid     = "ECSTaskAccess"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "foundry_server" {
  statement {
    sid = "AllowFoundryCredentialsKMSAccess"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt"
    ]
    resources = [aws_kms_key.foundry_server_credentials.arn]
  }

  statement {
    sid = "AllowFoundryCredentialsAccess"
    actions = [
      "ssm:GetParameter*",
    ]
    resources = compact([
      aws_ssm_parameter.foundry_username.arn,
      aws_ssm_parameter.foundry_password.arn,
      length(aws_ssm_parameter.foundry_admin_key) > 0 ? element(aws_ssm_parameter.foundry_admin_key.*.arn, 0) : ""
    ])
  }

  statement {
    sid = "S3ListAllBucketsAccess"
    actions = [
      "s3:ListAllMyBuckets",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid = "S3BucketAccess"
    actions = [
      "s3:GetBucket*",
      "s3:List*",
    ]
    resources = [
      aws_s3_bucket.foundry_artifacts.arn,
    ]
  }

  statement {
    sid = "S3BucketObjectGetAccess"
    actions = [
      "s3:GetObject*"
    ]
    resources = [
      "${aws_s3_bucket.foundry_artifacts.arn}/*"
    ]
  }

  statement {
    sid = "S3BucketObjectPutAccess"
    actions = [
      "s3:PutObject*"
    ]
    resources = [
      "${aws_s3_bucket.foundry_artifacts.arn}/data/${terraform.workspace}/*"
    ]
  }

  statement {
    sid = "EFSFoundryDataWriteAccess"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
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
    resources = [aws_efs_file_system.foundry_server_data.arn]
  }
}

resource "aws_iam_policy" "foundry_server" {
  description = "The core policy allowing basic access for a functioning foundry server."
  name_prefix = "foundry-server-${terraform.workspace}"
  policy      = data.aws_iam_policy_document.foundry_server.json
}

resource "aws_iam_role" "foundry_server" {
  assume_role_policy    = data.aws_iam_policy_document.foundry_server_assume_role.json
  description           = "Starts with the requirements for the foundry server to function."
  force_detach_policies = true
  name_prefix           = "foundry-server-${terraform.workspace}"
  tags                  = local.tags_rendered
}

resource "aws_iam_role_policy_attachment" "foundry_server" {
  role       = aws_iam_role.foundry_server.name
  policy_arn = aws_iam_policy.foundry_server.arn
}

resource "aws_iam_instance_profile" "foundry_server" {
  name_prefix = "foundry-server-profile-${terraform.workspace}"
  role        = aws_iam_role.foundry_server.name
}

output "role_arn" {
  description = "The ARN of the role the Foundry server uses to access credentials and the artifacts bucket."
  value       = aws_iam_role.foundry_server.arn
}

output "role_name" {
  description = "The name of the role the Foundry server uses to access credentials and the artifacts bucket."
  value       = aws_iam_role.foundry_server.name
}

output "instance_profile_arn" {
  description = "The ARN of the instance profile the Foundry server uses to access credentials and the artifacts bucket."
  value       = aws_iam_instance_profile.foundry_server.arn
}

output "instance_profile_id" {
  description = "The ID of the instance profile the Foundry server uses to access credentials and the artifacts bucket."
  value       = aws_iam_instance_profile.foundry_server.arn
}

output "instance_profile_name" {
  description = "The name of the instance profile the Foundry server uses to access credentials and the artifacts bucket."
  value       = aws_iam_instance_profile.foundry_server.name
}

output "policy_arn" {
  description = "The ARN of the policy attached to the Foundry server role."
  value       = aws_iam_policy.foundry_server.arn
}

output "policy_id" {
  description = "The ID of the policy attached to the Foundry server role."
  value       = aws_iam_policy.foundry_server.arn
}

output "policy_name" {
  description = "The name of the policy attached to the Foundry server role."
  value       = aws_iam_policy.foundry_server.name
}

