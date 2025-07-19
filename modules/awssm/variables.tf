variable "name" {
  type    = string
  default = "wtv"
}

variable "env" {
  description = "Environment name"
  type        = string
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
  default = "3306"
  type = string
}

variable "db_name" {
  description = "Database name"
  type = string
}

variable "flask_secret" {
  description = "Flask secret"
  type = string
}