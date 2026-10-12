output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}
output "private_subnet_ids" {
  value       = aws_subnet.private.*.id
  description = "IDs of the private subnets"
}
