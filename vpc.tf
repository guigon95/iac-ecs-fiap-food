resource "aws_vpc" "fiap-food-vpc" {
 cidr_block           = "192.168.0.0/16"
 enable_dns_support   = true
 enable_dns_hostnames = true


 tags = merge(local.common_tags, { Name : "Terraform-ECS-Fiap-Food VPC" })
}



resource "aws_subnet" "fiap-food-private-subnet" {
 for_each = {
  "priv_a" : ["192.168.1.0/24", "${var.aws_region}a", "Private A"]
  "priv_b" : ["192.168.2.0/24", "${var.aws_region}b", "Private B"]
 }

 vpc_id            = aws_vpc.fiap-food-vpc.id
 cidr_block        = each.value[0]
 availability_zone = each.value[1]


 tags = merge(local.common_tags, { Name : "Private A" })
}


