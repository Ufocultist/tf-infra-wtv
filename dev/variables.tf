variable "name" {
  type    = string
  default = "wtv"
}


variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "capacity_type" {
  default = "ON_DEMAND"
  type    = string
}

variable "instance_types" {
  default = ["t3.medium"]
  type    = list(string)
}

variable "ami_type" {
  default = "AL2_x86_64"
  type    = string
}

variable "k8s_version" {
  default = "1.32"
  type    = string
}

variable "env" {
  description = "Environment name"
  type        = string
}