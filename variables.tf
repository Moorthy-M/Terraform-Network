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

variable "role_name" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "assume_role_services" {
  type = list(string)
}

variable "policy_actions" {
  type = list(string)
}

variable "policy_resources" {
  type = list(string)
}


