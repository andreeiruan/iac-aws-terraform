resource "aws_ecr_repository" "repository" {
  name = var.service_name
}

resource "aws_codecommit_repository" "artifact_store" {
  repository_name = "${var.service_name}-artifacts"
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  memory                   = var.memory_task
  cpu                      = var.cpu_task
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([{
    name   = "${var.service_name}_container",
    image  = "nginx"
    memory = var.memory_container
    cpu    = var.cpu_container
    portMappings = [{
      containerPort = var.blue_port
      hostPort      = var.blue_port
    }]

    essential = true


    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs-cluster/${var.cluster_name}"
        awslogs-stream-prefix = "/ecs-task-output"
        awslogs-region        = data.aws_region.current.name
      }
    }

  }])
}

resource "aws_ecs_service" "service" {
  name                = var.service_name
  cluster             = aws_ecs_cluster.cluster.id
  task_definition     = aws_ecs_task_definition.task.arn
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  # wait_for_steady_state = true
  force_new_deployment = true


  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity.name
    weight            = 1
  }

  load_balancer {
    container_name   = "${var.service_name}_container"
    container_port   = var.blue_port
    target_group_arn = data.aws_lb_target_group.target_blue.arn
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.security_group_internal]
  }
}
