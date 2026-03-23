provider "aws" {
  region = "us-east-1"


 # assume_role {
  #   role_arn = "arn:aws:iam::808512682402:role/TF-role"
  #   session_name = "TF-access"
  # }

}
terraform {
  required_version = "1.14.3"
  required_providers {
    aws = {
      version = "~>6.35.1"
      source = "hashicorp/aws"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "the-stringer-things-terraform-state"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}