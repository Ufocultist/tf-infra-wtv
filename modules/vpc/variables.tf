variable "name" {
  type    = string
  default = "wtv"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "cidr_block" {
  description = "VPC Address space"
  type = string
}

variable "public_subnet_cidrs" {
  description = "Public Sub's cidrs"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private Sub's cidrs"
  type = list(string)
}

variable "azs" {
  description = "Availability zones"
  type = list(string)
}