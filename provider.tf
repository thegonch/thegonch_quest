# provider.tf

# Specify the provider and access details
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # vversion = "5.82.2" # latest version as of 2025-01-01, pin to maintain stability
    }
  }
}