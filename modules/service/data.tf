data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_lb_target_group" "target_blue" {
  arn = var.target_blue_arn
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}