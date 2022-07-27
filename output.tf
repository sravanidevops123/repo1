output "my_publi_ip" {
  value = aws_instance.web.public_ip
}
output "my_publi_dns" {
  value = aws_instance.web.public_dns
}
