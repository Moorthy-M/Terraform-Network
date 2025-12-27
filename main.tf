module "vpc" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//vpc?ref=vpc-v1.3"

  vpc_cidr             = var.vpc_cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat           = var.enable_nat
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  vpc_role_arn         = var.enable_vpc_flow_logs ? module.iam_flow_logs[0].role_arn : null
  tags                 = var.tags

  depends_on = [module.iam_flow_logs]
}

module "iam_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  source = "../modules/iam"

  role_name            = var.role_name
  assume_role_services = var.assume_role_services

  policy_name      = var.policy_name
  policy_actions   = var.policy_actions
  policy_resources = var.policy_resources

  tags = var.tags
}