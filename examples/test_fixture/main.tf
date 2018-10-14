provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

module "module_template" {
  source             = "../.."
  name               = "my_module"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
