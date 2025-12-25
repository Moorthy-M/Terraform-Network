module "vpc" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//vpc?ref=vpc-v1.1"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat      = var.enable_nat
  tags            = var.tags
}