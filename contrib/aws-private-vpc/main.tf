provider "aws" {}

locals {
  vpc_name = "adam-dev"
  region   = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "10.0.0.0/16"

  azs            = ["${local.region}a"]
  intra_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/28", "10.0.102.0/28"]

  enable_nat_gateway   = false
  enable_vpn_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  count           = length(module.vpc.intra_route_table_ids)
  route_table_id  = module.vpc.intra_route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}
