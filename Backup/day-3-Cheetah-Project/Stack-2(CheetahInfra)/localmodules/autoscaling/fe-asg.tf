locals {
  user_data_fe    = templatefile("${path.module}/include/user-data-fe.tpl", {
    envname         = var.env_name
    lb_dns_endpoint = var.nlb_dns_endpoint
    fe_app_bucket   = data.terraform_remote_state.app_buckets.outputs.fe_app_bucket
  })
}

resource "aws_iam_instance_profile" "fe_inst_profile" {
  name = "cheetah-${var.env_name}-access-profile-fe"
  role = aws_iam_role.fe_inst_role.name
}

resource "aws_security_group" "fe_asg_sg" {
  name        = "cheetah-${var.env_name}-fe-asg-sg"
  description = "Security group for ASG instances(frontend)."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_fe_ipv4_8084" {
  security_group_id = aws_security_group.fe_asg_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 8501
  ip_protocol       = "tcp"
  to_port           = 8501
}

resource "aws_vpc_security_group_ingress_rule" "allow_fe_ipv4_22" {
  security_group_id = aws_security_group.fe_asg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "fe_allow_all" {
  security_group_id = aws_security_group.fe_asg_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_launch_template" "fe_app_launch_template" {
  name_prefix   = "web-app-instance"
  image_id      = data.aws_ami.linux_2023.id
  instance_type = var.fe_instance_type

  user_data = base64encode(local.user_data_fe)
  key_name  = aws_key_pair.app_key_pair.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.fe_inst_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    subnet_id                   = var.subnet_id
    security_groups             = [aws_security_group.fe_asg_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "frontend_app_asg" {
  name                = "cheetah-${var.env_name}-fe-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id = aws_launch_template.fe_app_launch_template.id
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout = "0"

  tag {
    key                 = "created_by"
    value               = "cheetah-${var.env_name}-fe-asg"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "asg_alb_attachment" {
  autoscaling_group_name = aws_autoscaling_group.frontend_app_asg.name
  lb_target_group_arn    = var.alb_tg_arn
}