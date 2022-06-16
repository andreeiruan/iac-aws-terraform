resource "aws_lb" "network_elb" {
  name                             = "i-${var.service_name}-${var.major_version}-network"
  load_balancer_type               = "network"
  subnets                          = var.private_subnets
  internal                         = true
  enable_cross_zone_load_balancing = true
}
