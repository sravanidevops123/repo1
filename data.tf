data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "launch-wizard-4"
  vpc_id = data.aws_vpc.default.id
}
