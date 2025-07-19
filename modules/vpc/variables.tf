variable "name" {
  type    = string
  default = "wtv"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "cidr_block" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}