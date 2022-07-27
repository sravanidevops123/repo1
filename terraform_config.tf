terraform {
  backend "s3" {
    bucket = "mybucket-1213-2131"
    key    = "terraform-deploy-through-jenkins/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "mytable"
  }
}
