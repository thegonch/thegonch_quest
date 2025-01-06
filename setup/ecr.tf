# Create an ECR repository and a lifecycle policy for the repository.

resource "aws_ecr_repository" "gonchquest_ecr_repo" {
  name = "gonchquest-ecr-repo"
}

resource "aws_ecr_lifecycle_policy" "gonchquest_ecr_repo" {
  repository = aws_ecr_repository.gonchquest_ecr_repo.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep only a few of the last images",
        selection    = {
          tagStatus = "any",
          countType = "imageCountMoreThan",
          countNumber = 5,
        },
        action = {
          type = "expire",
        },
      },
    ],
  })
}