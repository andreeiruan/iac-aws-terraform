

resource "aws_subnet" "private_subnet_one" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "${var.ips_subnets[2]}/24"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]

  tags = {
    Name = "i-${var.env}-${var.infra_version}-private-subnet-one"
  }
}

resource "aws_subnet" "private_subnet_two" {
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "${var.ips_subnets[3]}/24"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]

  tags = {
    Name = "i-${var.env}-${var.infra_version}-private-subnet-two"
  }
}

resource "aws_network_acl" "private_acl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.private_subnet_one.id, aws_subnet.private_subnet_two.id]

  ingress {
    protocol   = -1
    rule_no    = 100
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
    Name = "i-${var.env}-${var.infra_version}-private_acl"
  }
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.gw]
  vpc        = true

  tags = {
    Name = "i-${var.env}-${var.infra_version}-eip-nat"
  }
}

resource "aws_nat_gateway" "nat_gatewway" {
  subnet_id     = aws_subnet.public_subnet_one.id
  allocation_id = aws_eip.eip.id

  tags = {
    Name = "i-${var.env}-${var.infra_version}-nat"
  }
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gatewway.id
  }

  tags = {
    Name = "i-${var.env}-${var.infra_version}-private-route-table"
  }
}

resource "aws_route_table_association" "priv_one" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.route_table_private.id
}

resource "aws_route_table_association" "priv_two" {
  subnet_id      = aws_subnet.private_subnet_two.id
  route_table_id = aws_route_table.route_table_private.id
}
