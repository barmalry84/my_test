data "aws_vpc" "precreated_vpc" {
    filter {
    name   = "tag:Name"
    values = ["vpc-qa"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

resource "aws_lb" "people_info_api" {
  name               = "people-info-api-alb"
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.people_info_api_alb_sg.id]
  subnets            = tolist(data.aws_subnets.public.ids)

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "people_info_api_tg" {
  for_each = {
    "status" = {
      name        = "people-info-tg-status"
      port        = 3000
      health_path = "/status"
    },
    "metrics" = {
      name        = "people-info-tg-metrics"
      port        = 5050
      health_path = "/metrics"
    }
  }

  name        = each.value.name
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.precreated_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = each.value.health_path
    port                = each.value.port
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "people_info_api_lst" {
  for_each = {
    "status" = {
      port            = "3000"
      target_group    = aws_lb_target_group.people_info_api_tg["status"].arn
    },
    "metrics" = {
      port            = "5050"
      target_group    = aws_lb_target_group.people_info_api_tg["metrics"].arn
    }
  }

  load_balancer_arn = aws_lb.people_info_api.arn
  port              = each.value.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.target_group
  }
}

resource "aws_security_group" "people_info_api_alb_sg" {
  name        = "people-info-api-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.precreated_vpc.id
}

resource "aws_security_group_rule" "people_info_api_alb_ingress_3000" {
  security_group_id = aws_security_group.people_info_api_alb_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "people_info_api_alb_ingress_5050" {
  security_group_id = aws_security_group.people_info_api_alb_sg.id
  type              = "ingress"
  from_port         = 5050
  to_port           = 5050
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "people_info_api_alb_egress" {
  security_group_id = aws_security_group.people_info_api_alb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}