output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "target group arn"
}

output "dns_loadbalancer" {
  value       = aws_lb.public.dns_name
  description = "dns name of the load balancer"
}
