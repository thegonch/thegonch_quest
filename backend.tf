terraform {
   backend "s3" {
    bucket         = "gonchquest-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    # shared_credentials_file = "~/.aws/credentials"
    # profile = "default"
    # dynamodb_table = "TerraformStateLocking"
  }
}