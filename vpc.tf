locals {
  subnet_public_arns = [aws_subnet.foundry_public_first.arn, aws_subnet.foundry_public_first.arn]
  subnet_public_azs  = [aws_subnet.foundry_public_first.availability_zone, aws_subnet.foundry_public_first.availability_zone]
  subnet_public_ids  = [aws_subnet.foundry_public_first.id, aws_subnet.foundry_public_first.id]
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

resource "aws_internet_gateway" "foundry" {
  vpc_id = aws_vpc.foundry.id
  tags   = merge(local.tags_rendered, map("Name", "foundry-gateway-${terraform.workspace}"))
}

resource "aws_route" "foundry_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.foundry.id
  route_table_id         = aws_vpc.foundry.main_route_table_id
}

output internet_gateway_arn {
  value = aws_internet_gateway.foundry.arn
}

output internet_gateway_id {
  value = aws_internet_gateway.foundry.id
}

output subnet_public_arns {
  value = local.subnet_public_arns
}

output subnet_public_azs {
  value = local.subnet_public_azs
}

output subnet_public_ids {
  value = local.subnet_public_ids
}

output vpc_arn {
  value = aws_vpc.foundry.arn
}

output vpc_cidr_block {
  value = aws_vpc.foundry.cidr_block
}

output vpc_main_route_table_id {
  value = aws_vpc.foundry.main_route_table_id
}

output vpc_id {
  value = aws_vpc.foundry.id
}