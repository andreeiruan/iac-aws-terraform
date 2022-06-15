variable "cluster_name" {}

variable "service_name" {}

variable "canary_interval" {}

variable "canary_percentage" {}

variable "blue_listener_https_arn" {}

variable "blue_listener_http_arn" {}

variable "target_blue_arn" {}

variable "target_green_arn" {}

variable "green_listener_http_arn" {}

variable "canary_cleanup_timeout" {}

variable "ecr_repository_name" {}

variable "use_https" {}

variable "codecommit_repository_name" {}

variable "pipeline_bucket_name" {}