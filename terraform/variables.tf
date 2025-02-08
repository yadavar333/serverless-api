variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "bookmarks"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}
