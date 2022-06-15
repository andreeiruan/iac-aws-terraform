resource "aws_subnet" "public_subnet_one" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "${var.ips_subnets[0]}/24"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]

  tags = {
    Name = "${var.cluster_name}-public-subnet-one"
  }
}

resource "aws_subnet" "public_subnet_two" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "${var.ips_subnets[1]}/24"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]

  tags = {
    Name = "${var.cluster_name}-public-subnet-two"
  }
}

resource "aws_network_acl" "public_acl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.public_subnet_one.id, aws_subnet.public_subnet_two.id]

  dynamic "ingress" {
    for_each = var.rules_ingress_public_acl
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  ingress {
    protocol   = -1
    rule_no    = 101
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.cluster_name}-public_acl"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}

resource "aws_route_table_association" "one" {
  subnet_id      = aws_subnet.public_subnet_one.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "two" {
  subnet_id      = aws_subnet.public_subnet_two.id
  route_table_id = aws_route_table.route_table_public.id
}
