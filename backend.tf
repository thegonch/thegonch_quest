# Configure the backend for the terraform state file.
# backend.tf
terraform {

   backend "s3" {
    bucket         = "gonchquest-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt       = true
  }
}