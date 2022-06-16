resource "aws_lb_target_group" "target_blue" {
  name        = "i-${var.service_name}-${var.major_version}-tg-blue"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
  port        = var.blue_port
  protocol    = "HTTP"

  health_check {
    matcher             = "200"
    path                = "/"
    interval            = 5
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 2
    enabled             = true
  }
}

resource "aws_lb_target_group" "target_green" {
  name        = "i-${var.service_name}-${var.major_version}-tg-green"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
  port        = var.green_port
  protocol    = "HTTP"

  health_check {
    matcher             = "200"
    path                = "/"
    interval            = 5
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 2
    enabled             = true
  }
}

