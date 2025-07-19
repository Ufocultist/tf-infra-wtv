variable "name" {
  type    = string
  default = "wtv"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  default = "us-east1"
  type = string
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
}

variable "repo_name" {
  type = string
}