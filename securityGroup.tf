# Load balancer security group. CIDR and port ingress can be changed as required.
resource "aws_security_group" "lb_security_group" {
  name        = "Terraform-ECS-Fiap-Food-ALB-SG"
  description = "SG-ALB-Fiap-Food"
  vpc_id = aws_vpc.fiap-food-vpc.id

  tags = merge(local.common_tags, { Name : "Terraform ECS ALB-SG" })

}

resource "aws_security_group_rule" "sg_ingress_rule_all_to_lb" {
  type	= "ingress"
  description = "Allow from anyone on port 80"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.lb_security_group.id
}

# Load balancer security group egress rule to ECS cluster security group.
resource "aws_security_group_rule" "sg_egress_rule_lb_to_ecs_cluster" {
  type	= "egress"
  description = "Target group egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}

# ECS cluster security group.
resource "aws_security_group" "ecs_security_group" {
  name        = "Terraform-ECS-Fiap-Food TASK SG"
  description = "Terraform-ECS-Fiap-Food SG"
  vpc_id      = aws_vpc.fiap-food-vpc.id

 ## ingress {
 ##   protocol        = "tcp"
 ##   from_port       = var.container_port
 ##   to_port         = var.container_port
 ##   security_groups = [aws_security_group.alb.id]
 ## }


  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS cluster security group ingress from the load balancer.
resource "aws_security_group_rule" "sg_ingress_rule_ecs_cluster_from_lb" {
  type	= "ingress"
  description = "Ingress from Load Balancer"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.lb_security_group.id
}