output "target_group_arns" {
  value       = aws_lb_target_group.app.arn
  description = "target group arns"
}

output "dns_loadbalancer" {
  value       = aws_lb.public.dns_name
  description = "dns name of the load balancer"
}
