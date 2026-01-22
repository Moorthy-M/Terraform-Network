data "aws_caller_identity" "current" {}

data "aws_cloudwatch_log_group" "vpcflowlogs" {
  count = var.enable_vpc_flow_logs && !var.flow_logs_bucket ? 1 : 0
  name  = "vpc/flow-logs"
}

data "aws_s3_bucket" "vpcflowlogs" {
  count  = var.enable_vpc_flow_logs && var.flow_logs_bucket ? 1 : 0
  bucket = "vpc-flow-logs-${data.aws_caller_identity.current.account_id}"
}

locals {
  flow_logs_destination = var.enable_vpc_flow_logs ? (var.flow_logs_bucket ? data.aws_s3_bucket.vpcflowlogs[0].arn : data.aws_cloudwatch_log_group.vpcflowlogs[0].arn) : null
  resources             = var.enable_vpc_flow_logs && var.flow_logs_bucket ? ["${data.aws_s3_bucket.vpcflowlogs[0].arn}/AWSLogs/*"] : []

  vpcflowlogs_policy = { for pol, obj in var.vpcflowlogs_policy : pol => merge(
    obj, {
      resources = concat(try(obj.resources, []), local.resources)
    }
  ) }
}

module "vpc" {
  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//vpc?ref=vpc-v2"

  vpc_cidr              = var.vpc_cidr
  public_subnets        = var.public_subnets
  private_subnets       = var.private_subnets
  enable_nat            = var.enable_nat
  enable_vpc_flow_logs  = var.enable_vpc_flow_logs
  vpc_flowlogs_role_arn = var.enable_vpc_flow_logs && !var.flow_logs_bucket ? module.iam_flow_logs[0].role_name_arns["vpcflowlogsrole"] : null
  flow_logs_destination = local.flow_logs_destination
  flow_logs_bucket      = var.flow_logs_bucket
  tags                  = var.tags

  depends_on = [module.iam_flow_logs]
}

module "iam_flow_logs_policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  source        = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/policy?ref=iam-v1"
  create_json   = var.flow_logs_bucket
  create_policy = local.vpcflowlogs_policy
  tags          = var.tags
}

module "iam_flow_logs" {
  count = var.enable_vpc_flow_logs && !var.flow_logs_bucket ? 1 : 0

  source = "git::https://github.com/Moorthy-M/Terraform-Modules.git//iam/role?ref=iam-v1"
  create_role = {
    for name, role in var.vpcflowlogs_role : name => merge(
      role, {
        permission_policy = concat(role.permission_policy, [module.iam_flow_logs_policy[0].policies["vpcflowlogspermission"]])
      }
    )
  }

  tags = var.tags

  depends_on = [module.iam_flow_logs_policy]
}

resource "aws_s3_bucket_policy" "vpcflowlogs" {
  count  = var.enable_vpc_flow_logs && var.flow_logs_bucket ? 1 : 0
  bucket = data.aws_s3_bucket.vpcflowlogs[0].id
  policy = module.iam_flow_logs_policy[0].policy_json["vpcflowlogspermission"]
}
