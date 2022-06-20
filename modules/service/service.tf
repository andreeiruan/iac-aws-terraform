resource "aws_ecr_repository" "repository" {
  name = "i-${var.env}-${var.infra_version}-i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-${var.major_version}"
}

resource "aws_codecommit_repository" "artifact_store" {
  depends_on = [
    aws_ecr_repository.repository
  ]
  repository_name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-artifacts"



  provisioner "local-exec" {
    command = "/bin/sh -c ./scripts/push-docker-local-image.sh"

    environment = {
      AWS_REGION         = data.aws_region.current.name
      IMAGE_LOCAL        = "${var.docker_image_local}:${var.docker_image_tag}"
      ECR_REPOSITORY_URI = aws_ecr_repository.repository.repository_url
      ECR_REGISTRY_ID    = aws_ecr_repository.repository.registry_id
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  depends_on = [
    aws_ecr_repository.repository,
    aws_codecommit_repository.artifact_store
  ]

  family                   = var.service_name
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  memory                   = var.memory_task
  cpu                      = var.cpu_task
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([{
    name   = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-container",
    image  = aws_ecr_repository.repository.repository_url
    memory = var.memory_container
    cpu    = var.cpu_container
    portMappings = [{
      containerPort = var.blue_port
      hostPort      = var.blue_port
    }]

    healthCheck = {
      command     = ["CMD-SHELL", "curl http://localhost:${var.blue_port}/"]
      interval    = 10
      retries     = 5
      startPeriod = 200
      timeout     = 10
    }

    essential = true

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs-cluster/i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}"
        awslogs-stream-prefix = "/ecs-task-output"
        awslogs-region        = data.aws_region.current.name
      }
    }

    environment = [
      {
        name  = "QUEUE_URL",
        value = var.queue_url
      }
    ]

  }])
}

resource "aws_ecs_service" "service" {
  name                = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}"
  cluster             = aws_ecs_cluster.cluster.id
  task_definition     = aws_ecs_task_definition.task.arn
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  # wait_for_steady_state = true  
  # launch_type           = "EC2"

  # lifecycle {
  #   ignore_changes = [
  #     task_definition
  #   ]
  # }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity.name
    weight            = 1
  }

  load_balancer {
    container_name   = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-container"
    container_port   = var.blue_port
    target_group_arn = data.aws_lb_target_group.target_blue.arn
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.security_group_internal]
  }
}
