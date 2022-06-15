variable "queue_name" {
  type        = string
  description = "The SQS queue name"
}

variable "visibility_timeout_seconds" {
  type        = number
  default     = 10
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30."
}

variable "message_retention_seconds" {
  type        = number
  default     = 86400
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)"
}

variable "max_message_size" {
  type        = number
  default     = 2048
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB)"
}

variable "delay_seconds" {
  type        = number
  default     = 0
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds"
}

variable "receive_wait_time_seconds" {
  type        = number
  default     = 0
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately"
}

variable "is_dead_letter_queue" {
  type        = bool
  description = "The dead letter queue to use for undeliverable messages"
}

variable "max_receive_count" {
  type        = number
  default     = 10
  description = "maxReceiveCount for the Dead Letter Queue redrive policy"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the queue"
}
