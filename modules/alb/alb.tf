resource "aws_security_group" "alb_security_group" {
  name        = "${var.cluster_name}-allow-web-server"
  description = "Enables access to all IPs"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(local.ports_sg_alb)
    content {
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "public_alb" {
  name               = "public-alb-${var.cluster_name}"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_security_group.id, var.security_group_internal_id]
  internal           = false
}


resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.subdomain}.${var.hosted_zone_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.public_alb.dns_name]

  lifecycle {
    ignore_changes = [
      zone_id
    ]
  }
}

