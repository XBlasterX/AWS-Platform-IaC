output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_ssm.name
  description = "Name of the EC2 instance profile for SSM"
}

output "flow_log_role_arn" {
  value       = aws_iam_role.vpc_flow_logs.arn
  description = "ARN of IAM role for VPC Flow Logs"
}
