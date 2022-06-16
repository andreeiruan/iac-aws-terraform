resource "aws_ecs_cluster" "cluster" {
  name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "capacity" { 
  name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.autoscaling_group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_provider" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.capacity.name]
}
