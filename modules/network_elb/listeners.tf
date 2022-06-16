resource "aws_lb_listener" "blue_listener_protocol_http" {  
  load_balancer_arn = aws_lb.network_elb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_blue.arn
  }
}

resource "aws_lb_listener" "green_listener_http" {
  load_balancer_arn = aws_lb.network_elb.arn
  port              = var.green_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_green.arn
  }
}
