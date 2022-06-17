variable "canary_interval" {}

variable "canary_percentage" {}

# variable "blue_listener_https_arn" {
#   default = ""
# }

# variable "blue_listener_http_arn" {}

variable "target_blue_arn" {}

variable "target_green_arn" {}

# variable "green_listener_http_arn" {}

variable "listener_https" {}

variable "canary_cleanup_timeout" {}

variable "ecr_repository_name" {}

variable "use_https" {}

variable "env" {
  
}

variable "infra_version" {
  
}

variable "service_name" {
  
}

variable "major_version" {
  
}

variable "service_ecs_name" {
  
}

variable "cluster_name" {
  
}

variable "codecommit_repository_name" {}

variable "task_family" {}

variable "container_name" {}

variable "exec_task_role_arn" {}

variable "networw_lb" {
  default = false
}