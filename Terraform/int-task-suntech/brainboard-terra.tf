locals {
  common_tags = {
    env      = "Examples"
    archUUID = "4f0dc4bd-6ed1-4426-b04e-da7a424bd0f3"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(local.common_tags, {
    Name = "main"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "igw"
  })
}

resource "aws_eip" "nat_eip_1" {
  tags = merge(local.common_tags, {
    Name = "nat_eip_1"
  })
}

resource "aws_eip" "nat_eip_2" {
  tags = merge(local.common_tags, {
    Name = "nat_eip_2"
  })
}

resource "aws_nat_gateway" "nat_gw_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.nat_eip_1.id

  tags = merge(local.common_tags, {
    Name = "nat_gw_1"
  })
}

resource "aws_nat_gateway" "nat_gw_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  allocation_id = aws_eip.nat_eip_2.id

  tags = merge(local.common_tags, {
    Name = "nat_gw_2"
  })
}

resource "aws_lb" "alb" {
  name               = "enterprise-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = merge(local.common_tags, {
    Name = "alb"
  })
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "web_sg"
  })
}

resource "aws_security_group_rule" "web_sg_rule" {
  security_group_id = aws_security_group.web_sg.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "public_subnet_1"
  })
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = merge(local.common_tags, {
    Name = "public_subnet_2"
  })
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = merge(localcommon_tags, {
    Name = "private_subnet_1"
  })
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = merge(local.common_tags, {
    Name = "private_subnet_2"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "public_rt"
  })
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_autoscaling_group" "asg" {
  name_prefix           = "enterprise-asg-"
  max_size              = 5
  min_size              = 2
  desired_capacity      = 2
  health_check_type     = "ELB"
  health_check_grace_period = 300
  force_delete          = true
  launch_configuration  = aws_launch_configuration.lc.id
  vpc_zone_identifier   = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tag {
    key                 = "Name"
    value               = "enterprise-asg"
    propagate_at_launch = true
  }

  tags = merge(local.common_tags, {})
}

resource "aws_launch_configuration" "lc" {
  name_prefix     = "enterprise-lc-"
  image_id        = "ami-0c94855ba95b798c7" # This is an example Amazon Linux 2 AMI ID; replace with the desired AMI ID
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "enterprise-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  tags = merge(local.common_tags, {
    Name = "enterprise-s3-bucket"
  })
}

resource "aws_efs_file_system" "efs" {
  performance_mode      = "generalPurpose"
  throughput_mode       = "bursting"
  encrypted             = true

  tags = merge(local.common_tags, {
    Name = "enterprise-efs"
  })
}

resource "aws_efs_mount_target" "efs_mount_target_1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "efs_mount_target_2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet_2.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Security group for EFS"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "efs_sg"
  })
}

resource "aws_security_group_rule" "efs_sg_rule" {
  security_group_id = aws_security_group.efs_sg.id

  type        = "ingress"
  from_port   = 2049
  to_port     = 2049
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8"] # Replace with the required CIDR blocks
}