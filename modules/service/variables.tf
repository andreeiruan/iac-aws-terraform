variable "cluster_name" {}

variable "keypair_name" {}

variable "ecs_image_id" {}

variable "security_group_internal" {}

variable "instance_type" {}

variable "asg_min_instances" {}

variable "asg_desired_instances" {}

variable "asg_max_instances" {}

variable "target_blue_arn" {}

variable "public_subnet" {}

variable "vpc_id" {}

variable "ecs_node_volume_size" {
  type = number
}

#TASK
variable "memory_task" {
  type = number
}

variable "cpu_task" {
  type = number
}

#CONTAINER
variable "memory_container" {
  type = number
}

variable "cpu_container" {
  type = number
}

variable "blue_port" {
  type = number
}

variable "green_port" {
  type = number
}

variable "service_name" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}
