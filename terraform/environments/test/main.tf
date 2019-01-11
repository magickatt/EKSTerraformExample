# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "eks-terraform-example" {
  source = "../../modules/test"
}
