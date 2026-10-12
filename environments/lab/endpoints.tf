resource "aws_vpc_endpoint" "ssm" {
  for_each = toset([
    "ssm",
    "ssmmessages",
  ])
  vpc_id              = module.network.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.network.private_subnet_ids
  private_dns_enabled = true
  security_group_ids  = [module.security.vpc_endpoints_sg_id]
  tags = {
    "Name" = "production-platform-${each.key}.endpoint"
  }
}
