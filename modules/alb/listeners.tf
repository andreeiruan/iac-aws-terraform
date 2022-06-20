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

resource "aws_lb_listener" "blue_listener_protocol_https" {
  count             = var.use_https ? 1 : 0
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      protocol    = "HTTPS"
      port        = "443"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
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


resource "aws_lb_listener" "blue_listener_https" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.certificate_manager[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_blue.arn
  }
}

# resource "aws_lb_listener_rule" "service_rule_blue" {
#   listener_arn = aws_lb_listener.listener_https.arn
#   priority     = var.site_priority_blue

#   condition {
#     host_header {
#       values = ["${var.subdomain}.${var.hosted_zone_domain}"]
#     }
#   }

#   action {
#     target_group_arn = aws_lb_target_group.target_blue.arn
#     type             = "forward"
#   }
# }

# resource "aws_lb_listener_rule" "service_rule_green" {
#   listener_arn = aws_lb_listener.listener_https.arn
#   priority     = var.site_priority_green

#   condition {
#     host_header {
#       values = ["${var.subdomain}.${var.hosted_zone_domain}"]
#     }
#   }

#   action {
#     target_group_arn = aws_lb_target_group.target_green.arn
#     type             = "forward"
#   }
# }


resource "aws_lb_listener_certificate" "service_certificate" {
  listener_arn    = aws_lb_listener.blue_listener_https.arn
  certificate_arn = aws_acm_certificate.certificate_manager[0].arn
}
