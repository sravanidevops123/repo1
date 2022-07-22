provider "aws" {

}


data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "launch-wizard-4"
  vpc_id = data.aws_vpc.default.id
}




resource "aws_instance" "web" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "ap-south-1a"
  key_name          = var.key_name
  security_groups   = [data.aws_security_group.default.name]

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time provisioner'"
  }
  
  provisioner "file" {
    source      = "TestWebApp/target/TestWebApp.war"
    destination = "/opt/TestWebApp.war"
  }
  
  connection {
    type     = "ssh"
    user     = "ec2-user"
    #password = var.root_password
    private_key = file('myLap.pem')
    host     = self.public_ip
  }
  
  provisioner "remote-exec" {
    script="downloadjdk8Tomcat.sh"
  }
  
  provisioner "remote-exec" {
    script="deployAndStartTomcat.sh"
  }
    
  tags = {
    Name = "Tommy"
  }
}

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



output "my_publi_ip" {
  value = aws_instance.web.public_ip
}
output "my_publi_dns" {
  value = aws_instance.web.public_dns
}



variable "ami_id" {
  default = "ami-08df646e18b182346"
}

variable "instance_type" {
  default = "t2.micro"
}


variable "key_name" {
  default="myLap"
}

variable "vpc_id" {
  default = "vpc-71d6021a"
}
