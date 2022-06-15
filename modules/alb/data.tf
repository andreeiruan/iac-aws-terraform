data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone_domain
  private_zone = false
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}
