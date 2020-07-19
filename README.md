# terraform-aws-foundryvtt

Stand up a completely turn-key, secure Foundry Virtual Tabletop server using Terraform.

- [terraform-aws-foundryvtt](#terraform-aws-foundryvtt)
 - [Description](#description)
 - [Prerequisites](#prerequisites)
 - [Source](#source)
 - [Requirements](#requirements)
 - [Inputs](#inputs)
 - [Outputs](#outputs)

## Description  
Creates a fully managed VPC housing your server utilizing ECS behind a load balancer. AWS will safely manage your secrets and Foundry data in conjunction with the server to maintain availability and consistency...while still leaving you in control.

This is the module for you if:  
1. You are looking to quickly create a containerized FoundryVTT server  
2. You enjoy the security and consistency of the AWS cloud platform  
3. You don't want to be encumbered by hefty management and configuration  
4. You just want to play D&D (or any other role playing tabletop game, of course!)

## Prerequisites  
1. [Foundry Virtual Tabletop license](https://foundryvtt.com/purchase/)  
2. [Terraform 12 or higher](https://warrensbox.github.io/terraform-switcher/)  
3. AWS account with an automation role for Terraform to use on your behalf

## Source  
First you'll need to decide which version to use. I recommend using the [latest release tag](https://github.com/Justinon/terraform-aws-foundryvtt/releases) if you can. Otherwise, search for the one that suits you.  
You can create the module with the source and version of choice using the [Terraform Registry path](https://registry.terraform.io/modules/Justinon/foundryvtt/aws):

```HCL
module "foundryvtt_example" {
  source  = "Justinon/foundryvtt/aws"
  version = "X.Y.Z"
  # insert the required variables here
  ...
}
```

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 2.68.0 |
| template | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_account\_id | The root user of the AWS account provided will be the sole credentials KMS key administrator. | `string` | n/a | yes |
| aws\_automation\_role\_arn | The automation role used by Terraform. Gets decrypt/encrypt access to KMS credentials key. | `string` | n/a | yes |
| foundry\_password | Will be encrypted in AWS Parameter Store for exclusive use by the server to securely obtain and use the Foundry license. | `string` | n/a | yes |
| foundry\_username | Will be encrypted in AWS Parameter Store for exclusive use by the server to securely obtain and use the Foundry license. | `string` | n/a | yes |
| artifacts\_bucket\_public | Whether or not the artifacts bucket should be public. To reuse this bucket for direct Amazon S3 asset storage in browser, set to true. | `bool` | `true` | no |
| artifacts\_data\_expiration\_days | The amount of days after which non-current version of the artifacts bucket Foundry data is expired. | `number` | `30` | no |
| foundry\_admin\_key | The Admin Access Key to set for password-protecting administration access to the Foundry tool. Will be encrypted in AWS Parameter Store for exclusive use by the server. | `string` | `""` | no |
| foundryvtt\_docker\_image | Probably won't work with other images yet but the option is there if you want to experiment | `string` | `"felddy/foundryvtt:release"` | no |
| security\_groups | Any extra security groups to associate with the Foundry server. | `list` | `[]` | no |
| tags | Any additional AWS tags you want associated with all created and eligible resources. | <pre>list(object({<br>    key   = string,<br>    value = string<br>  }))</pre> | `[]` | no |
| vpc\_cidr\_block | The CIDR block of the Foundry VPC housing all created and eligible resources. | `string` | `"20.0.0.0/22"` | no |

## Outputs

| Name | Description |
|------|-------------|
| artifacts\_bucket\_arn | The ARN of the S3 bucket holding versioned Foundry data. |
| artifacts\_bucket\_name | The name of the S3 bucket holding versioned Foundry data. |
| credentials\_kms\_key\_arn | The ARN of the KMS key used by the server to decrypt and encrypt Foundry credentials. Used exclusively to maintain consistency and legitimacy of the server and license respectively. |
| credentials\_kms\_key\_id | The ID of the KMS key used by the server to decrypt and encrypt Foundry credentials. Used exclusively to maintain consistency and legitimacy of the server and license respectively. |
| internet\_gateway\_arn | The ARN of the Internet Gateway allowing internet access to public subnets in the Foundry VPC. |
| internet\_gateway\_id | The ID of the Internet Gateway allowing internet access to public subnets in the Foundry VPC. |
| lb\_arn | The ARN of the application load balancer in front of the Fargate task serving the Foundry container. |
| lb\_dns\_name | The main entrypoint to the Foundry tool for users and GMs. Is the DNS name of the application load balancer in front of the Fargate task serving the Foundry container. Can be used with Route53. |
| lb\_zone\_id | The Route53 zone ID of the application load balancer in front of the Fargate task serving the Foundry container. |
| policy\_arn | The ARN of the policy attached to the Foundry server role. |
| policy\_id | The ID of the policy attached to the Foundry server role. |
| policy\_name | The name of the policy attached to the Foundry server role. |
| role\_arn | The ARN of the role the Foundry server uses to access credentials and the artifacts bucket. |
| role\_name | The name of the role the Foundry server uses to access credentials and the artifacts bucket. |
| subnet\_private\_arns | The ARN of the private subnets housing the fargate foundry task. |
| subnet\_private\_azs | The availability zones of the private subnets housing the fargate foundry task. |
| subnet\_private\_ids | The IDs of the private subnets housing the fargate foundry task. |
| subnet\_public\_arns | The ARN of the public subnets housing the server autoscaling group and load balancer. |
| subnet\_public\_azs | The availability zones of the public subnets housing the server autoscaling group and load balancer. |
| subnet\_public\_ids | The IDs of the public subnets housing the server autoscaling group and load balancer. |
| target\_group\_http\_arn | The ARN of the HTTP target group receiving traffic from the HTTP ALB listener. |
| target\_group\_http\_name | The name of the HTTP target group receiving traffic from the HTTP ALB listener. |
| target\_group\_https\_arn | The ARN of the HTTPS target group receiving traffic from the HTTPS ALB listener. |
| target\_group\_https\_name | The name of the HTTPS target group receiving traffic from the HTTPS ALB listener. |
| vpc\_arn | The ARN of the Foundry VPC housing all created and eligible resources. |
| vpc\_cidr\_block | The CIDR block of the Foundry VPC housing all created and eligible resources. |
| vpc\_id | The ID of the Foundry VPC housing all created and eligible resources. |
| vpc\_route\_table\_private\_id | The private route table for the Foundry VPC. |
| vpc\_route\_table\_public\_id | The public route table for the Foundry VPC. |

