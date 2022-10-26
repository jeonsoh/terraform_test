variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
}

variable "aws_role_arn" {
  description = "AWS AssumeRole ARN"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr_block" {
  description = "AWS VPC CIDR block"
  type        = string
}

variable "private_subnets" {
  description = "AWS Private Subnet CIDR blocks"
  type        = list
}

variable "public_subnets" {
  description = "AWS Public Subnet CIDR blocks"
  type        = list
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "efs_csi_filesystem_id" {
  description = ""
  type        = string
  default     = "fs-004c54d77f3ce8f36"
}