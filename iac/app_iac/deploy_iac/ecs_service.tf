resource "aws_security_group" "people_info_api_sg" {
  name        = "people_info_api-sg"
  description = "Allow traffic for API"
  vpc_id      = data.aws_vpc.precreated_vpc.id
}

resource "aws_security_group_rule" "people_info_api_sg_rules" {
  for_each          = toset([for subnet in data.aws_subnets.private : subnet.cidr_block])
  security_group_id = aws_security_group.people_info_api_sg.id

  dynamic "ingress_rule" {
    for_each = [3000, 5050]

    content {
      type        = "ingress"
      from_port   = ingress_rule
      to_port     = ingress_rule
      protocol    = "tcp"
      cidr_blocks = [each.key]
    }
  }

  dynamic "alb_ingress_rule" {
    for_each = [3000, 5050]

    content {
      type                     = "ingress"
      from_port                = alb_ingress_rule
      to_port                  = alb_ingress_rule
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.people_info_api_sg.id
    }
  }

  egress_rule {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "people_info_api" {
  name            = "people-info-api-service"
  cluster         = aws_ecs_cluster.people_info_api_cluster.id
  task_definition = aws_ecs_task_definition.people-info-api.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = tolist(data.aws_subnets.private.ids)
    security_groups = [aws_security_group.people_info_api_sg.id]
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.precreated_tg_status.arn
    container_name   = "people-info-api"
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.precreated_tg_metrics.arn
    container_name   = "people-info-api"
    container_port   = 5050
  }

  desired_count = 3

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "people_info_api" {
  family                   = "people-info-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.api_ecs_role.arn
  task_role_arn            = aws_iam_role.api_ecs_role.arn

  container_definitions = jsonencode([{
    name  = "people-info-api"
    image = "${data.aws_ecr_repository.people-info-api.repository_url}:var.image_version"

    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
      },
      {
        containerPort = 5050
        hostPort      = 5050
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/people-info-api"
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])
}