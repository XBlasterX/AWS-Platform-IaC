output "vpc_endpoints_sg_id" {
  value       = aws_security_group.vpc_endpoints.id
  description = "ID of the security group for VPC endpoints"
}
