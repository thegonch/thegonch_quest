# ecr.tf

resource "aws_ecr_repository" "gonchquest_ecr_repo" {
  name = "gonchquest-ecr-repo"
}