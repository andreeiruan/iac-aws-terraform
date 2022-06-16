variable "region" {
  type        = string
  description = "AWS Region"
}

variable "service_name" {
  type = string
}

variable "major_version" {
  type = string
}

variable "env" {
  type = string
}

variable "infra_version" {
  type = string
}

variable "blue_port" {
  type = number
}

variable "green_port" {
  type = number
}

variable "use_https" {
  type = bool
}

variable "docker_image_local" {
  type = string
}

variable "docker_image_tag" {
  type    = string
  default = "latest"
}
