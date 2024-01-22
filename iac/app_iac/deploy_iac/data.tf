data "aws_ecs_cluster" "people_info_api_cluster" {
  cluster_name = "people-info-api-cluster"
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

data "aws_vpc" "precreated_vpc" {
  name = "vpc-qa"
}

data "aws_lb_target_group" "precreated_tg_status" {
  name = "people-info-tg-status"
}

data "aws_lb_target_group" "precreated_tg_metrics" {
  name = "people-info-tg-metrics"
}

data "aws_ecr_repository" "precreated_ecr" {
  name       = "people-info-api"
}