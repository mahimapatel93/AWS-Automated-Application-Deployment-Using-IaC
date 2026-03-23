resource "aws_lb_target_group" "alb_target_group" {
  name     = "cheetah-${var.env_name}-frontend-tg"
  port     = 8501
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    port     = 8501
    path     = "/"
  }

  tags = {
    Name = "cheetah-${var.env_name}-frontend-tg"
  }
}

resource "aws_lb" "alb" {
  name               = "cheetah-${var.env_name}-frontend-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "cheetah-${var.env_name}-frontend-alb"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "cheetah-${var.env_name}-alb-sg"
  description = "Security group for application load balancer."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_ipv4_80" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}