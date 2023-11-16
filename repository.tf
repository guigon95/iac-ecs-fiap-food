resource "aws_ecr_repository" "fiap-food" {
  name                 = "fiap-food"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}