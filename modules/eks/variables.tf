variable "name" {
  type    = string
  default = "wtv"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region for the EKS cluster"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for constructing ARNs"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "private_subnet_ids" {
  description = "Private Sub's"
  type = list(string)
}

variable "eks_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
}

variable "eks_node_group_role_arn" {
  description = "EKS Node group role arn"
  type = string
}

variable "capacity_type" {
  description = "Worker Node Instance"
  default = "ON_DEMAND"
  type    = string
}

variable "instance_types" {
  description = "Worker Node Instance Type"
  default = ["t3.medium"]
  type    = list(string)
}

variable "ami_type" {
  description = "Worker node AMI"
  default = "AL2_x86_64"
  type    = string
}

variable "k8s_version" {
  description = "EKS Kubernetes version"
  default = "1.29"
  type    = string
}