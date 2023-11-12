# Create the ECS Cluster and Fargate launch type service in the private subnets
resource "aws_ecs_cluster" "ecs_cluster" {
 name = var.cluster_name
}


resource "aws_ecs_task_definition" "ecs_task_def" {
 family                   = var.cluster_task
 container_definitions    = <<DEFINITION
 [
   {
     "name": "${var.cluster_task}",
     "image": "${var.image_url}",
     "essential": true,
     "portMappings": [
       {
         "containerPort": ${var.container_port},
         "hostPort": ${var.container_port}
       }
     ],
     "memory": ${var.memory},
     "cpu": ${var.cpu}
   }
 ]
 DEFINITION
 requires_compatibilities = ["FARGATE"]
 network_mode             = "awsvpc"
 memory                   = var.memory
 cpu                      = var.cpu
 execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn
}


resource "aws_iam_role" "ecs_task_exec_role" {
 name               = "ecs_task_exec_role"
 assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


data "aws_iam_policy_document" "assume_role_policy" {
 statement {
   actions = ["sts:AssumeRole"]


   principals {
     type        = "Service"
     identifiers = ["ecs-tasks.amazonaws.com"]
   }
 }
}


resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
 role       = aws_iam_role.ecs_task_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource "aws_ecs_service" "fiap-food-ecs-service" {
 name                = var.cluster_service
 cluster             = aws_ecs_cluster.ecs_cluster.id
 task_definition     = aws_ecs_task_definition.ecs_task_def.arn
 launch_type         = "FARGATE"
 ##scheduling_strategy = "REPLICA"
 desired_count       = var.desired_capacity
 depends_on      = [aws_lb_target_group.alb_ecs_tg, aws_lb_listener.ecs_alb_listener]


 load_balancer {
   target_group_arn = aws_lb_target_group.alb_ecs_tg.arn
   container_name   = aws_ecs_task_definition.ecs_task_def.family
   container_port   = var.container_port
 }


 network_configuration {
   subnets          = [aws_subnet.fiap-food-private-subnet["priv_a"].id, aws_subnet.fiap-food-private-subnet["priv_b"].id]
   security_groups  = [aws_security_group.ecs_security_group.id]
 }
}

# Create the VPC Link configured with the private subnets. Security groups are kept empty here, but can be configured as required.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name        = "vpclink_apigw_to_alb"
  security_group_ids = []
  subnet_ids = [aws_subnet.fiap-food-private-subnet["priv_a"].id, aws_subnet.fiap-food-private-subnet["priv_b"].id]
}

# Create the API Gateway HTTP endpoint
resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = "serverlessland-pvt-endpoint"
  protocol_type = "HTTP"
}

# Create the API Gateway HTTP_PROXY integration between the created API and the private load balancer via the VPC Link.
# Ensure that the 'DependsOn' attribute has the VPC Link dependency.
# This is to ensure that the VPC Link is created successfully before the integration and the API GW routes are created.
resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.ecs_alb_listener.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  payload_format_version = "1.0"
  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb,
    aws_apigatewayv2_api.apigw_http_endpoint,
    aws_lb_listener.ecs_alb_listener]
}

# API GW route with ANY method
resource "aws_apigatewayv2_route" "apigw_route" {
  api_id    = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key = "ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on  = [aws_apigatewayv2_integration.apigw_integration]
}

# Set a default stage
resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id = aws_apigatewayv2_api.apigw_http_endpoint.id
  name   = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.apigw_http_endpoint]
}

# Generated API GW endpoint URL that can be used to access the application running on a private ECS Fargate cluster.
output "apigw_endpoint" {
  value = aws_apigatewayv2_api.apigw_http_endpoint.api_endpoint
  description = "API Gateway Endpoint"
}



