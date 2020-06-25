# foundryvtt-terraform

Stand up a completely turn-key, secure Foundry Virtual Tabletop server using Terraform.

- [foundryvtt-terraform](#foundryvtt-terraform)
  - [Description](#description)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
    - [Source](#source)
    - [Variables](#variables)
  - [Services and Resources Used](#services-and-resources-used)

## Description
Creates a fully managed VPC housing your server behind an autoscaling group and load balancer. AWS will safely manage your secrets and Foundry data in conjunction with the server to maintain availability and consistency...while still leaving you in control.

This is the module for you if:
1. You are looking to quickly create a containerized FoundryVTT server
2. You enjoy the security and consistency of the AWS cloud platform
3. You don't want to be encumbered by hefty management and configuration
4. You just want to play D&D (or any other role playing tabletop game, of course!)

## Prerequisites
1. [Foundry Virtual Tabletop license](https://foundryvtt.com/purchase/)
2. [Terraform 12 or higher](https://warrensbox.github.io/terraform-switcher/)
3. AWS account with an automation role for Terraform to use on your behalf

## Usage

First you'll need to decide which version to use. I recommend using the [latest release tag](https://github.com/Justinon/foundryvtt-terraform/releases) if you can. Otherwise, search for the one that suits you.

### Source
You can create the module with the source and version of choice using either SSH or HTTPS:

SSH:
```HCL
module "foundryvtt_example" {
    source = "git@github.com:Justinon/foundryvtt-terraform.git?ref=<VERSION>"
    ...
}
```
HTTPS:
```HCL
module "foundryvtt_example" {
    source = "github.com/Justinon/foundryvtt-terraform?ref=<VERSION>"
    ...
}
```

### Variables
At minimum, *foundryvtt-terraform* requires the following variables:
1. `aws_account_id`: The AWS account ID to which Terraform will deploy resources
2. `aws_automation_role_arn`: The ARN of the role used by Terraform to act on your behalf
3. `foundry_password`: The Foundry password used by the server to obtain your license
4. `foundry_username`: The Foundry username used by the server to obtain your license
5. `home_ip_address`: The IP address from which the server will allow SSH access
6. `region`: The AWS region in which Terraform will deploy resources

Some other optional but useful variables include:
1. `ebs_block_devices`: List of objects representing any EBS block devices you want to attach to the server
2. `foundry_admin_key`: The Admin Access Key to set for password-protecting administration access to the Foundry tool
3. `security_groups`: List of any additional security group IDs to attach to the server
4. `tags`: List of any additional tags to add to eligible *foundryvtt-terraform* resources

For more variables, checkout the Terraform documentation page for the module.

## Services and Resources Used
* **EC2**
  * **ALB/Listener**
    * LB DNS serves as the main endpoint for the server
    * Currently set to listen on port `80` (`https` support coming soon)
  * **ASG**
    * Used to maintain availability and consistency of a single instance
    * Desired capacity is ignored so that you can freely spin the server up/down
  * **Launch Configuration**
    * Uses Amazon Linux 2 AMI
    * User data script will:
      1. Install `docker` and other dependencies
      2. Pull existing Foundry data from artifacts bucket if it exists
      3. Start the server container
      4. Create daily cron job to backup Foundry data
  * **Security Group/Security Group Rule**
    * LB:
      * Ingress: `80` from the world
      * Egress: `30000` to the server
    * Server:
      * Ingress: `30000` from LB, `22` from provided IP address
      * Egress: The world
  * **Target Group**
* **IAM**
  * **Instance Profile**
  * **Policy/Policy Attachment**
  * **Role**
* **KMS**
  * **Key**
    * Used to encrypt foundry credentials
    * Administration access given to root account user
    * Encrypt/decrypt access given to server role and Terraform automation role
* **SSM**
  * **Parameter**
    * One for each of foundry username, password, and admin key.
    * Encrypted by foundry KMS key
* **S3**
  * **Bucket/Public Access Block**
    * Artifacts bucket holds any Foundry server data
    * Non-current versions of data get deleted after a month
* **VPC**
  * **Internet Gateway**
  * **Route**
  * **Subnet**
    * Two public subnets to hold the foundry server and load balancer
  * **VPC**
    * Single foundry VPC for isolation
    * Every eligible resource created by *foundryvtt-terraform* will be placed in the VPC