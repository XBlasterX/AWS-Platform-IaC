variable "alb_arn_suffix" {
  type        = string
  description = "ARN suffix of the Application Load Balancer"
}

variable "target_group_arn_suffix" {
  type        = string
  description = "ARN suffix of the ALB Target Group"
}

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch metrics"
}