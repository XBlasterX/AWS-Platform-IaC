resource "aws_flow_log" "vpc" {
  vpc_id               = module.network.vpc_id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = module.monitoring.flow_log_group_arn
  iam_role_arn         = module.iam.flow_log_role_arn

  depends_on = [module.iam]
}