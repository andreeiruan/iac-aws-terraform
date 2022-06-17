resource "aws_codedeploy_app" "app" {  
  name             = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-application"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_config" "deploy_config" {
  depends_on = [
    aws_codedeploy_app.app
  ]
  deployment_config_name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-deployment-config"
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
  depends_on = [
    aws_iam_role.code_deploy_role,
    aws_codedeploy_app.app,
    aws_codedeploy_deployment_config.deploy_config
  ]
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}-deploy-group"


  service_role_arn = aws_iam_role.code_deploy_role.arn

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

  deployment_config_name = var.networw_lb != true ? aws_codedeploy_deployment_config.deploy_config.deployment_config_name : "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_ecs_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.use_https == true ? [var.listener_https] : [var.listener_https]
      }


      target_group {
        name = data.aws_lb_target_group.target_green.name
      }

      target_group {
        name = data.aws_lb_target_group.target_blue.name
      }

      # test_traffic_route {
      #   listener_arns = [var.listener_https]
      # }
    }


  }
}
