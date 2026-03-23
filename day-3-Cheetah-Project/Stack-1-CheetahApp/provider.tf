provider "aws" {
  region = "us-east-1"

  assume_role {
     role_arn ="arn:aws:iam::162343470963:role/terraform-assume-role"
     session_name = "TF-session"
   }
}

terraform {
  required_version = "1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }
  backend "s3" {
    bucket       = "dev-mahi-app-infra-s3-bucket"
    key          = "envs/dev/app/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}