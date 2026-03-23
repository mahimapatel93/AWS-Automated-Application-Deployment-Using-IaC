resource "aws_lb_target_group" "nlb_target_group" {
  name     = "cheetah-${var.env_name}-backend-tg"
  port     = 8084
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    port     = 8084
    path     = "/actuator"
  }

  tags = {
    Name = "cheetah-${var.env_name}-backend-tg"
  }
}

resource "aws_lb" "net_lb" {
  name               = "cheetah-${var.env_name}-backend-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
  enable_deletion_protection = false
  security_groups    = [aws_security_group.nlb_sg.id]

  tags = {
    Name = "cheetah-${var.env_name}-backend-nlb"
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.net_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

resource "aws_security_group" "nlb_sg" {
  name        = "cheetah-${var.env_name}-nlb-sg"
  description = "Security group for network load balancer."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_be_ipv4_8084" {
  security_group_id = aws_security_group.nlb_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_be_ipv4_22" {
  security_group_id = aws_security_group.nlb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.nlb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}