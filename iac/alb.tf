# Security Group para el ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${var.project_name}"
  description = "Permitir trafico HTTP entrante"
  vpc_id      = aws_vpc.vpc_bearozz.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-${var.project_name}"
  }
}

# Application Load Balancer
resource "aws_lb" "alb_bearozz" {
  name               = "alb-${var.project_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "alb-${var.project_name}"
  }
}

# Target Group para ECS Fargate
resource "aws_lb_target_group" "tg_bearozz" {
  name        = "tg-${var.project_name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_bearozz.id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tg-${var.project_name}"
  }
}

# Listener en puerto 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_bearozz.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_bearozz.arn
  }
}
