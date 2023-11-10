locals {


 subnet_ids = { for k, v in aws_subnet.this : v.tags.Name => v.id }


 common_tags = {
   Project   = "ECS Fargate"
   CreatedAt = "2023-11-08"
   ManagedBy = "Fiap Food"
   Owner     = "Fiap Food"
   Service   = "ECS Fargate"
 }
}
