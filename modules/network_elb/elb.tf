resource "aws_lb_target_group" "network_elb_default_target_group" {
  name     = "network-tg-${var.cluster_name}-default"
  vpc_id   = data.aws_vpc.vpc.id
  port     = 80
  protocol = "TCP"

  health_check {    
    port                = 80    
    interval            = 10
    protocol            = "TCP"    
    healthy_threshold   = 3    
  }
}

resource "aws_lb" "network_elb" {
  name                             = "network-lb${var.cluster_name}"
  load_balancer_type               = "network"
  subnets                          = var.private_subnets
  internal                         = true
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "network_listener_elb_http" {
  load_balancer_arn = aws_lb.network_elb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network_elb_default_target_group.arn
  }
}
