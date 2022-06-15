resource "aws_cloudwatch_log_group" "yada" {
  name = "/ecs-cluster/${var.cluster_name}"
}