output "target_blue_arn" {
  value = aws_lb_target_group.target_blue.arn
}

output "target_green_arn" {
  value = aws_lb_target_group.target_green.arn
}

output "blue_listener_protocol_arn" {
  value = aws_lb_listener.blue_listener_protocol_http.arn 
}

output "green_listener_http_arn" {
  value = aws_lb_listener.green_listener_http.arn
}