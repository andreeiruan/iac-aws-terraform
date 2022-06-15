data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_lb_target_group" "target_blue" {
  arn = var.target_blue_arn
}