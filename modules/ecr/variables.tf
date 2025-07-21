variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags are mutable or immutable"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Images scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Will delete the repository even if it contains images"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}