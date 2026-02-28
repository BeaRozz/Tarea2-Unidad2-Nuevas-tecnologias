# ECS Cluster bearozz
resource "aws_ecs_cluster" "cluster_bearozz" {
  name = "cluster-${var.project_name}"

  tags = {
    Name = "ecs-cluster-${var.project_name}"
  }
}

# Log Group para los contenedores
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "ecs-logs-${var.project_name}"
  }
}

# Task Definition de Fargate
resource "aws_ecs_task_definition" "task_bearozz" {
  family                   = "task-${var.project_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "container-${var.project_name}"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "task-def-${var.project_name}"
  }
}

# Security Group para el Servicio ECS (solo permite trafico desde el ALB)
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg-${var.project_name}"
  description = "Permitir trafico solo desde el ALB"
  vpc_id      = aws_vpc.vpc_bearozz.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg-${var.project_name}"
  }
}

# Servicio ECS Fargate
resource "aws_ecs_service" "service_bearozz" {
  name            = "service-${var.project_name}"
  cluster         = aws_ecs_cluster.cluster_bearozz.id
  task_definition = aws_ecs_task_definition.task_bearozz.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_bearozz.arn
    container_name   = "container-${var.project_name}"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "service-${var.project_name}"
  }
}
