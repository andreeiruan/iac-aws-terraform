variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "hosted_zone_domain" {
  type = string
}

variable "domain_name_certifate" {
  type = string
}

variable "security_group_internal_id" {
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

variable "subdomain" {
  type = string
}
