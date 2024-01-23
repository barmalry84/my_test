resource "aws_security_group" "people_info_api_sg" {
  name        = "people_info_api-sg"
  description = "Allow traffic for API"
  vpc_id      = data.aws_vpc.precreated_vpc.id
}

resource "aws_security_group_rule" "people_info_api_ingress_status" {
  for_each = toset([for s in data.aws_subnet.private : s.cidr_block])

  security_group_id = aws_security_group.people_info_api_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [each.key]
}

resource "aws_security_group_rule" "alb_ecs_ingress_status" {
  security_group_id        = aws_security_group.people_info_api_sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.precreated_alb_sg.id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.people_info_api_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_ecs_service" "people_info_api" {
  name            = "people-info-api-service"
  cluster         = data.aws_ecs_cluster.people_info_api_cluster.id
  task_definition = aws_ecs_task_definition.people_info_api.arn
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

  desired_count = 1

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
  execution_role_arn       = data.aws_iam_role.precreated_iam.arn
  task_role_arn            = data.aws_iam_role.precreated_iam.arn

  container_definitions = jsonencode([{
    name  = "people-info-api"
    image = "${data.aws_ecr_repository.precreated_ecr.repository_url}:${var.image_version}"

    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/people-info-api"
        "awslogs-region"        = "eu-west-1"
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])
}