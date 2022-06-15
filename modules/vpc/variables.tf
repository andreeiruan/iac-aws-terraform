variable "cluster_name" {
  type = string
}

variable "cidr_ip" {
  type    = string
  default = "10.10.0.0"
}

variable "ips_subnets" {
  type    = list(string)
  default = ["10.10.30.0", "10.10.40.0", "10.10.20.0", "10.10.10.0"]
}

variable "rules_ingress_public_acl" {
  default = [
    {
      protocol   = "tcp"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 443
      to_port    = 443
    },
    {
      protocol   = "tcp"
      rule_no    = 110
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 22
      to_port    = 22
    },
  ]
}
