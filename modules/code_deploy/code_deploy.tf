resource "aws_codedeploy_app" "app" {
  name             = "${var.service_name}-application"  
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_config" "deploy_config" {
  depends_on = [
    aws_codedeploy_app.app
  ]
  deployment_config_name = "${var.service_name}-deployment-config"
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "TimeBasedCanary"

    time_based_canary {
      interval   = var.canary_interval
      percentage = var.canary_percentage
    }

  }
}

resource "aws_codedeploy_deployment_group" "deploy_group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.service_name}-deploy-group"

  service_role_arn = aws_iam_role.ecs_execution_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.canary_cleanup_timeout
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
  }

  deployment_config_name = aws_codedeploy_deployment_config.deploy_config.deployment_config_name

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.use_https == true ? [var.blue_listener_https_arn] : [var.blue_listener_http_arn]
      }

      target_group {
        name = data.aws_lb_target_group.target_blue.name
      }

      target_group {
        name = data.aws_lb_target_group.target_green.name
      }

      test_traffic_route {
        listener_arns = [var.green_listener_http_arn]
      }
    }

  
  }
}
