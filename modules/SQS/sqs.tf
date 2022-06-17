locals {
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "queue_deadletter" {
  count                      = var.is_dead_letter_queue ? 1 : 0
  name                       = "i-${var.env}-${var.infra_version}-deadletter"
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
}

resource "aws_sqs_queue" "queue" {
  name                       = "i-${var.env}-${var.infra_version}"
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  redrive_policy             = var.is_dead_letter_queue == true ? local.redrive_policy : null  
  tags                       = var.tags
}
