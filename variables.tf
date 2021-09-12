variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "aws_vpc_cidr" {
  type        = string
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  validation {
    condition     = cidrnetmask(var.aws_vpc_cidr) == cidrnetmask("10.0.0.0/16")
    error_message = "Invalid aws_vpc_cidr, should be a /16 block."
  }
}

variable "aws_vpc_name" {
  type = string
}

variable "aws_zones" {
  type    = list(any)
  default = ["a", "b", "c"]
}
