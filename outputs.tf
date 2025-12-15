output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}

output "key_name" {
  value = aws_key_pair.my_keypair.key_name
}
