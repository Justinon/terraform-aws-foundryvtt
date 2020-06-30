locals {
  subnet_private_arns = [aws_subnet.foundry_private_first.arn, aws_subnet.foundry_private_second.arn]
  subnet_private_azs  = [aws_subnet.foundry_private_first.availability_zone, aws_subnet.foundry_private_second.availability_zone]
  subnet_private_ids  = [aws_subnet.foundry_private_first.id, aws_subnet.foundry_private_second.id]
  subnet_public_arns  = [aws_subnet.foundry_public_first.arn, aws_subnet.foundry_public_second.arn]
  subnet_public_azs   = [aws_subnet.foundry_public_first.availability_zone, aws_subnet.foundry_public_second.availability_zone]
  subnet_public_ids   = [aws_subnet.foundry_public_first.id, aws_subnet.foundry_public_second.id]
}

resource "aws_vpc" "foundry" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags                 = merge(local.tags_rendered, map("Name", "foundry-${terraform.workspace}"))
}

resource "aws_subnet" "foundry_public_first" {
  availability_zone = element(local.server_availability_zones, 0)
  cidr_block        = "20.0.0.0/24"
  tags              = merge(local.tags_rendered, map("Name", "foundry-public-first-${terraform.workspace}"))
  vpc_id            = aws_vpc.foundry.id
}

resource "aws_subnet" "foundry_public_second" {
  availability_zone = element(local.server_availability_zones, 1)
  cidr_block        = "20.0.1.0/24"
  tags              = merge(local.tags_rendered, map("Name", "foundry-public-second-${terraform.workspace}"))
  vpc_id            = aws_vpc.foundry.id
}

resource "aws_subnet" "foundry_private_first" {
  availability_zone = element(local.server_availability_zones, 0)
  cidr_block        = "20.0.3.0/24"
  tags              = merge(local.tags_rendered, map("Name", "foundry-private-first-${terraform.workspace}"))
  vpc_id            = aws_vpc.foundry.id
}

resource "aws_subnet" "foundry_private_second" {
  availability_zone = element(local.server_availability_zones, 1)
  cidr_block        = "20.0.4.0/24"
  tags              = merge(local.tags_rendered, map("Name", "foundry-private-second-${terraform.workspace}"))
  vpc_id            = aws_vpc.foundry.id
}

resource "aws_route_table" "foundry_public" {
  vpc_id = aws_vpc.foundry.id
  tags   = merge(local.tags_rendered, map("Name", "foundry-public-${terraform.workspace}"))
}

resource "aws_internet_gateway" "foundry" {
  vpc_id = aws_vpc.foundry.id
  tags   = merge(local.tags_rendered, map("Name", "foundry-gateway-${terraform.workspace}"))
}

resource "aws_route" "foundry_internet_gw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.foundry.id
  route_table_id         = aws_route_table.foundry_public.id
}

resource "aws_route_table" "foundry_private" {
  vpc_id = aws_vpc.foundry.id
  tags   = merge(local.tags_rendered, map("Name", "foundry-private-${terraform.workspace}"))
}

resource "aws_route" "foundry_nat_gw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.foundry.id
  route_table_id         = aws_route_table.foundry_private.id
}

resource "aws_eip" "nat" {
  vpc  = aws_vpc.foundry_id
  tags = merge(local.tags_rendered, map("Name", "foundry-nat-${terraform.workspace}"))
}

resource "aws_nat_gateway" "foundry" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.foundry_private_first.id
  tags          = merge(local.tags_rendered, map("Name", "foundry-nat-${terraform.workspace}"))
}

output internet_gateway_arn {
  description = "The ARN of the Internet Gateway allowing internet access to public subnets in the Foundry VPC."
  value       = aws_internet_gateway.foundry.arn
}

output internet_gateway_id {
  description = "The ID of the Internet Gateway allowing internet access to public subnets in the Foundry VPC."
  value       = aws_internet_gateway.foundry.id
}

output subnet_public_arns {
  description = "The ARN of the public subnets housing the server autoscaling group and load balancer."
  value       = local.subnet_public_arns
}

output subnet_public_azs {
  description = "The availability zones of the public subnets housing the server autoscaling group and load balancer."
  value       = local.subnet_public_azs
}

output subnet_public_ids {
  description = "The IDs of the public subnets housing the server autoscaling group and load balancer."
  value       = local.subnet_public_ids
}

output subnet_private_arns {
  description = "The ARN of the private subnets housing the fargate foundry task."
  value       = local.subnet_private_arns
}

output subnet_private_azs {
  description = "The availability zones of the private subnets housing the fargate foundry task."
  value       = local.subnet_private_azs
}

output subnet_private_ids {
  description = "The IDs of the private subnets housing the fargate foundry task."
  value       = local.subnet_private_ids
}

output vpc_arn {
  description = "The ARN of the Foundry VPC housing all created and eligible resources."
  value       = aws_vpc.foundry.arn
}

output vpc_cidr_block {
  description = "The CIDR block of the Foundry VPC housing all created and eligible resources."
  value       = aws_vpc.foundry.cidr_block
}

output vpc_route_table_public_id {
  description = "The public route table for the Foundry VPC."
  value       = aws_route_table.foundry_public.id
}

output vpc_route_table_private_id {
  description = "The private route table for the Foundry VPC."
  value       = aws_route_table.foundry_private.id
}

output vpc_id {
  description = "The ID of the Foundry VPC housing all created and eligible resources."
  value       = aws_vpc.foundry.id
}
