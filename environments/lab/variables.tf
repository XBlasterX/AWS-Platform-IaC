variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "availability_zone" {
  type        = list(string)
  description = "Availability zones"
}
