data "aws_caller_identity" "current" {}

data "aws_cloudwatch_log_group" "vpcflowlogs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "vpc/flow-logs"
}

module "vpc" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//vpc?ref=vpc-v2"

  vpc_cidr              = var.vpc_cidr
  public_subnets        = var.public_subnets
  private_subnets       = var.private_subnets
  enable_nat            = var.enable_nat
  enable_vpc_flow_logs  = var.enable_vpc_flow_logs
  vpc_flowlogs_role_arn = var.enable_vpc_flow_logs ? module.iam_flow_logs[0].role_name_arns["vpcflowlogsrole"] : null
  flow_logs_destination = var.enable_vpc_flow_logs ? data.aws_cloudwatch_log_group.vpcflowlogs[0].arn : null
  flow_logs_bucket      = false

  tags = var.tags
}

module "iam_flow_logs_policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  source        = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/policy?ref=v1.release"
  create_policy = var.vpcflowlogs_policy
  tags          = var.tags
}

module "iam_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/role?ref=v1.release"
  create_role = {
    "vpcflowlogsrole" = {
      trust = {
        type        = "Service"
        identifiers = ["vpc-flow-logs.amazonaws.com"]
      }

      permission_policy = [module.iam_flow_logs_policy[0].policies["vpcflowlogspermission"]]
    }
  }

  tags = var.tags

  depends_on = [module.iam_flow_logs_policy]
}
