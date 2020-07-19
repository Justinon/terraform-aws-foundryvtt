/**
 * # terraform-aws-foundryvtt
 *
 * Stand up a completely turn-key, secure Foundry Virtual Tabletop server using Terraform.
 * 
 * - [terraform-aws-foundryvtt](#terraform-aws-foundryvtt)
 *  - [Description](#description)
 *  - [Prerequisites](#prerequisites)
 *  - [Source](#source)
 *  - [Requirements](#requirements)
 *  - [Inputs](#inputs)
 *  - [Outputs](#outputs)
 *
 * ## Description
 * Creates a fully managed VPC housing your server utilizing ECS behind a load balancer. AWS will safely manage your secrets and Foundry data in conjunction with the server to maintain availability and consistency...while still leaving you in control.
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
 * ## Source
 * First you'll need to decide which version to use. I recommend using the [latest release tag](https://github.com/Justinon/terraform-aws-foundryvtt/releases) if you can. Otherwise, search for the one that suits you.
 * You can create the module with the source and version of choice using the [Terraform Registry path](https://registry.terraform.io/modules/Justinon/foundryvtt/aws):
 *
 * ```HCL
 * module "foundryvtt_example" {
 *   source  = "Justinon/foundryvtt/aws"
 *   version = "X.Y.Z"
 *   # insert the required variables here
 *   ...
 * }
 * ```
 */


terraform {
  required_providers {
    aws = {
      version = "~> 2.68.0"
    }
    template = {
      version = "~> 2.1"
    }
  }
}
