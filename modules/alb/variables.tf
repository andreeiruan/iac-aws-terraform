variable "env" {
  
}

variable "infra_version" {
  
}

variable "service_name" {
  
}

variable "major_version" {
  
}

# variable "site_priority_green" {
  
# }

# variable "site_priority_blue" {
  
# }

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "hosted_zone_domain" {
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
