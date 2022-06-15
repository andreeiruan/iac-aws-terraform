data "aws_region" "current" {}

data "aws_lb_target_group" "target_blue" {
  arn = var.target_blue_arn
}

data "aws_lb_target_group" "target_green" {
  arn = var.target_green_arn
}

data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.pipeline_bucket_name
}
