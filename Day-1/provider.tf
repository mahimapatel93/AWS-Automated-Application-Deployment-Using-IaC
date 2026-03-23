provider "aws" {
    region = "us-east-1"
  
   assume_role {
     role_arn ="arn:aws:iam::875778602097:role/TF-role"
     session_name = "TF-session"
   }
}

 terraform {
   required_version = "1.14.3"
   required_providers {
     aws = {
         version = "5.0.0"
         source = "hashicorp/aws"
     }
  }
}