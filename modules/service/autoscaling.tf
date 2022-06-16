resource "aws_launch_configuration" "as_conf" {
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id
  key_name                    = var.keypair_name
  image_id                    = var.ecs_image_id
  security_groups             = [var.security_group_internal]
  instance_type               = var.instance_type
  associate_public_ip_address = false

  root_block_device {
    volume_size = var.ecs_node_volume_size
  }

  user_data = <<EOF
    #!/bin/bash
    #====== Resize EBS
      resize2fs /dev/xvda       

    #====== Install SSM
      yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      start amazon-ssm-agent
      chkconfig amazon-ssm-agent on

    #====== Install AWSLOGS
      yum install -y awslogs
      mv /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.bkp      
      sed -i "s/clustername/i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}/g" /etc/awslogs/awslogs.conf
      sed -i "s/instanceID/`curl -s http://169.254.169.254/latest/meta-data/instance-id`/g" /etc/awslogs/awslogs.conf
      service awslogs start
      chkconfig awslogs on

    echo ECS_CLUSTER=i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version} >> /etc/ecs/ecs.config
    echo ECS_INSTANCE_ATTRIBUTES={\"cluster_type\":\"web\"} >> /etc/ecs/ecs.config
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = var.asg_min_instances
  desired_capacity     = var.asg_desired_instances
  max_size             = var.asg_max_instances
  vpc_zone_identifier  = var.private_subnets

  tag {
    key                 = "Name"
    value               = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version} node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}_scale_up"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 1
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "i-${var.env}-${var.infra_version}-${var.service_name}-${var.major_version}_scale_down"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 1
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}


