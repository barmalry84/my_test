data "aws_ecs_cluster" "people_info_api_cluster" {
  cluster_name = "people-info-api-cluster"
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_vpc" "precreated_vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-qa"]
  }
}

data "aws_lb_target_group" "precreated_tg_status" {
  name = "people-info-tg-status"
}

data "aws_ecr_repository" "precreated_ecr" {
  name       = "people-info-api"
}

data "aws_iam_role" "precreated_iam" {
  name = "people-info-api-ecs-role"
}

data "aws_security_group" "precreated_alb_sg" {
  name = "people-info-api-alb-sg"
}
