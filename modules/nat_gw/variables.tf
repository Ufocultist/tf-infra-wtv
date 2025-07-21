variable "name" {
  type    = string
  default = "wtv"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID to attach to public route table"
}

variable "public_subnet_ids" {
  description = "Public Sub's"
  type = list(string)
}

variable "private_subnet_ids" {
  description = "Private Sub's"
  type = list(string)
}