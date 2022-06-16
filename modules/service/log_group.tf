resource "aws_cloudwatch_log_group" "yada" {
  name = "/ecs-cluster/i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}"
}