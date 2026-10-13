variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ec2_instance_profile_name" {
  type        = string
  description = "Name of the EC2 instance profile for SSM"
}

variable "ec2_security_group_ids" {
  type        = string
  description = "List of security group IDs for EC2 instances"
}

variable "target_group_arns" {
  type        = list(string)
  description = "List of target group ARNs for ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EC2 instances"
}