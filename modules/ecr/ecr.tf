resource "aws_ecr_repository" "main" {
  name = "{var.environment}-{var.region}-{var.repo_name}"
  image_tag_mutability = "IMMUTABLE"
  #tfsec:ignore:aws-ecr-repository-customer-key
  #checkov:skip=CKV_AWS_136: "Ensure that ECR repositories are encrypted using KMS"
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}