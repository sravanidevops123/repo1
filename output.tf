output "my_publi_ip" {
  value = aws_instance.web.public_ip
}

output "my_instance_id" {
  value = aws_instance.web.id
}

output "my_publi_dns" {
  value = aws_instance.web.public_dns
}
