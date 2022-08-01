resource "aws_instance" "web" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "ap-south-1a"
  key_name          = var.key_name
    
  tags = {
    Name = "Tommy"
  }
}
