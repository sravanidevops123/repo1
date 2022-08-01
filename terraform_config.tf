terraform {
  backend "s3" {
    bucket = "mybucket-1213-2131"
    key    = "build-and-deploy-pipeline-terraform-ec2-ansible-1/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "mytable"
  }
}
