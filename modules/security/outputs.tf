output "vpc_endpoints_sg_id" {
  value       = aws_security_group.vpc_endpoints.id
  description = "ID of the security group for VPC endpoints"
}

output "ec2_security_group_ids" {
  value       = aws_security_group.ec2.id
  description = "ec2 sec group"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "security group id for ALB"
}
