resource "aws_ecr_repository" "aws_backend_ecr_repo" {
  name                  = var.ecr_repo_name
  image_tag_mutability  = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}