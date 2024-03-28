resource "aws_ecr_repository" "fiap-food" {
  name                 = "order-fiap-food"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}