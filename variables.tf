variable "aws_access_key" {
  type        = string
  description = "use env aws keys"
}

variable "aws_secret_key" {
  type        = string
  description = "use env aws keys"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "desired_capacity" {
  description = "desired number of running nodes"
  default     = 2
}

variable "container_port" {
  default = "8080"
}

variable "image_url" {
  default = "860076335049.dkr.ecr.us-east-2.amazonaws.com/fiapfood:latest"
}

variable "memory" {
  default = "512"
}

variable "cpu" {
  default = "256"
}

variable "cluster_name" {
  default = "fiap-food-cluster"
}

variable "cluster_task" {
  default = "fiap-food-task"
}
variable "cluster_service" {
  default = "fiap-food-service"
}