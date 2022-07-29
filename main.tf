resource "aws_instance" "web" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "ap-south-1a"
  key_name          = var.key_name
  security_groups   = [data.aws_security_group.default.name]

  provisioner "local-exec" {
    #when    = destroy
    command = <<EOT
	  echo "${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.key_name}.pem" > hosts;
    export ANSIBLE_HOST_KEY_CHECKING=False;
    cat hosts
	  ansible-playbook -i hosts jdk8_tomcat_deploy.yml
    EOT
  }
    
  tags = {
    Name = "Tommy"
  }
}

/*
resource "aws_ebs_volume" "example" {
  availability_zone = "ap-south-1a"
  size              = 10

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.web.id
}
*/
