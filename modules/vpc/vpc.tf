resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_ip}/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  tags = {
    Name = "${var.cluster_name}-ig-vpc"
  }
}

resource "aws_internet_gateway_attachment" "gw" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.vpc.id
}

resource "aws_security_group" "allow_internal_access" {
  name        = "${var.cluster_name}-allow-iternal-access"
  description = "Enables access to all VPC protocols and IPs"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    description = "Allow access to all ips of vpc"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
