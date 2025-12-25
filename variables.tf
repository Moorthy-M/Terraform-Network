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

