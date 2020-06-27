/**
 * # terraform-aws-foundryvtt
 *
 * Stand up a completely turn-key, secure Foundry Virtual Tabletop server using Terraform.
 * 
 * - [terraform-aws-foundryvtt](#terraform-aws-foundryvtt)
 * - [Description](#description)
 * - [Prerequisites](#prerequisites)
 * - [Usage](#usage)
 *   - [Source](#source)
 *   - [Variables](#variables)
 * - [Services and Resources Used](#services-and-resources-used)
 *
 * ## Description
 * Creates a fully managed VPC housing your server behind an autoscaling group and load balancer. AWS will safely manage your secrets and Foundry data in conjunction with the server to maintain availability and consistency...while still leaving you in control.
 *
 * This is the module for you if:
 * 1. You are looking to quickly create a containerized FoundryVTT server
 * 2. You enjoy the security and consistency of the AWS cloud platform
 * 3. You don't want to be encumbered by hefty management and configuration
 * 4. You just want to play D&D (or any other role playing tabletop game, of course!)
 *
 * ## Prerequisites
 * 1. [Foundry Virtual Tabletop license](https://foundryvtt.com/purchase/)
 * 2. [Terraform 12 or higher](https://warrensbox.github.io/terraform-switcher/)
 * 3. AWS account with an automation role for Terraform to use on your behalf
 *
 * ## Usage
 *
 * First you'll need to decide which version to use. I recommend using the [latest release tag](https://github.com/Justinon/terraform-aws-foundryvtt/releases) if you can. Otherwise, search for the one that suits you.
 *
 * ### Source
 * You can create the module with the source and version of choice using either SSH or HTTPS:
 *
 * SSH:
 * ```HCL
 * module "foundryvtt_example" {
 *   source = "git@github.com:Justinon/terraform-aws-foundryvtt.git?ref=<VERSION>"
 *   ...
 * }
 * ```
 * HTTPS:
 * ```HCL
 * module "foundryvtt_example" {
 *   source = "github.com/Justinon/terraform-aws-foundryvtt?ref=<VERSION>"
 *   ...
 * }
 * ```
 *
 * ### Variables
 * At minimum, *terraform-aws-foundryvtt* requires the following variables:
 * 1. `aws_account_id`: The AWS account ID to which Terraform will deploy resources
 * 2. `aws_automation_role_arn`: The ARN of the role used by Terraform to act on your behalf
 * 3. `foundry_password`: The Foundry password used by the server to obtain your license
 * 4. `foundry_username`: The Foundry username used by the server to obtain your license
 * 5. `home_ip_address`: The IP address from which the server will allow SSH access
 * 6. `region`: The AWS region in which Terraform will deploy resources
 *
 * For more variables, checkout the [Input section](#input) below.
 */


terraform {
  required_providers {
    aws = {
      version = ">= 2.68.0"
    }
    template = {
      version = ">= 2.1"
    }
  }
}
