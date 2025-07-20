variable "name" {
  type    = string
  default = "wtv"
}

variable "app_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
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

variable "db_username" {
  description = "Database username"
  type        = string
}
variable "db_password" {
  description = "DB user Password"
  type        = string
}

variable "db_root_password" {
  description = "Database root password"
  type        = string
}

variable "db_host" {
  description = "Database Host"
  default     = "mariadb"
  type        = string
}

variable "db_port" {
  description = "Database port"
  default     = "3306"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "flask_secret" {
  description = "Flask secret"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
}

variable "repo_name" {
  type = string
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images"
  type        = bool
  default     = true
}