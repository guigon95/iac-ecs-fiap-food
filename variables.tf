variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-2"
}

variable "account_id" {
  type    = string
}

variable "access_key" {
  type    = string
}

variable "secret_key" {
  type    = string
}

variable "desired_capacity" {
  description = "desired number of running nodes"
  default     = 2
}

variable "container_port" {
  default = "8080"
}

variable "image_url" {
  default = "860076335049.dkr.ecr.us-east-2.amazonaws.com/order-fiap-food:latest"
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