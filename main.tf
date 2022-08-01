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
    EOT
  }
lifecycle{
	create_before_destroy=true
}
    
  tags = {
    Name = "Tommy"
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_instance.web]

  destroy_duration = "30s"
}

resource "null_resource" "script"{
	depends_on=[time_sleep.wait_30_seconds, aws_instance.web]
  provisioner "local-exec" {
    #when    = destroy
    command = <<EOT
    export ANSIBLE_HOST_KEY_CHECKING=False;
    cat hosts
	  ansible-playbook -i hosts jdk8_tomcat_deploy.yml
    EOT
  }
}


