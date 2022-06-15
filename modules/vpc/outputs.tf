output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "sg_allow_internal_access_id" {
  value = aws_security_group.allow_internal_access.id
}

output "subnet_public_one_id" {
  value = aws_subnet.public_subnet_one.id
}

output "subnet_public_two_id" {
  value = aws_subnet.public_subnet_two.id
}

output "subnet_private_one_id" {
  value = aws_subnet.private_subnet_one.id
}

output "subnet_private_two_id" {
  value = aws_subnet.private_subnet_two.id
}
