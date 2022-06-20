output "target_blue_arn" {
  value = aws_lb_target_group.target_blue.arn
}

output "target_green_arn" {
  value = aws_lb_target_group.target_green.arn
}

output "blue_listener_protocol_arn" {
  value = var.use_https == false ? aws_lb_listener.blue_listener_protocol_http[0].arn : aws_lb_listener.blue_listener_protocol_https[0].arn
}

output "blue_listener_https_arn" {
  value = aws_lb_listener.blue_listener_https.arn
}


# output "listener_https" {
#   value = aws_lb_listener.listener_https.arn
# }

output "green_listener_http_arn" {
  value = aws_lb_listener.green_listener_http.arn
}