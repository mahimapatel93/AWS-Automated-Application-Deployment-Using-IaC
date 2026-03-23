locals {
  user_data   = templatefile("${path.module}/include/user-data-be.tpl", {
    envname         = var.env_name
    rds_db_endpoint = var.rds_db_endpoint
    rds_db_uname    = var.rds_db_uname
    rds_db_passwd   = data.aws_ssm_parameter.rds_db_password.value
    jar_file        = var.jar_file_name
    be_app_bucket   = data.terraform_remote_state.app_buckets.outputs.be_app_bucket
  })
}

resource "aws_security_group" "be_asg_sg" {
  name        = "cheetah-${var.env_name}-asg-sg"
  description = "Security group for ASG instances(backend)."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_be_ipv4_8084" {
  security_group_id = aws_security_group.be_asg_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 8084
  ip_protocol       = "tcp"
  to_port           = 8084
}

resource "aws_vpc_security_group_ingress_rule" "allow_be_ipv4_22" {
  security_group_id = aws_security_group.be_asg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.be_asg_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_key_pair" "app_key_pair" {
  key_name   = "cheetah-${var.env_name}-key"
  public_key = file("${path.module}/include/mykey.pub")
}

resource "aws_iam_instance_profile" "be_profile" {
  name = "cheetah-${var.env_name}-access-profile"
  role = aws_iam_role.be_inst_role.name
}

resource "aws_launch_template" "backend_app_launch_template" {
  name_prefix          = "app-instance"
  image_id             = data.aws_ami.linux_2023.id
  instance_type        = var.instance_type

  user_data            = base64encode(local.user_data)
  key_name             = aws_key_pair.app_key_pair.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.be_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    subnet_id                   = var.subnet_id
    security_groups             = [aws_security_group.be_asg_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend_app_asg" {
  name                 = "cheetah-${var.env_name}-asg"
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.backend_app_launch_template.id
    version = "$Latest"
  }

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete               = true
  wait_for_capacity_timeout  = "0"

  tag {
    key                 = "created_by"
    value               = "cheetah-${var.env_name}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.backend_app_asg.name
  lb_target_group_arn    = var.nlb_tg_arn
}