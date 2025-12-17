output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}

output "ssh_private_key" {
  value     = tls_private_key.terraform_key.private_key_pem
  sensitive = true
}

output "ansible_server_public_ip" {
  value = aws_instance.ansible.public_ip
}

output "docker_server_public_ip" {
  value = aws_instance.docker_server.public_ip
}
