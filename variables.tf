variable "tags" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = map(object(
    {
      cidr_block        = string
      availability_zone = string
      nat               = optional(bool, false)
    }
  ))
}

variable "private_subnets" {
  type = map(object(
    {
      cidr_block        = string
      availability_zone = string
      tier              = string
    }
  ))
}

variable "enable_nat" {
  type = bool
}

//VPC - Flow Logs

variable "enable_vpc_flow_logs" {
  type = bool
}

variable "vpcflowlogs_policy" {
  type = map(object({
    sid       = optional(string, null)
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = list(string)

    principal = optional(object({
      type        = string
      identifiers = list(string)
    }))

  }))
}

variable "vpcflowlogs_role" {
  type = map(object({
    trust = object({
      type        = string
      identifiers = list(string)
    })

    managed_policy    = optional(list(string), [])
    permission_policy = optional(list(string), [])
  }))
}

variable "flow_logs_bucket" {
  type    = bool
  default = false
}
