resource "aws_lb_listener" "blue_listener_protocol_http" {
  count             = var.use_https ? 0 : 1
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_blue.arn
  }
}

resource "aws_lb_listener" "green_listener_http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = var.green_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_green.arn
  }
}
