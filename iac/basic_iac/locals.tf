locals {
  name             = "vpc-qa"
  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  ecr_name         = "people-info-api"
  ecs_cluster_name = "people-info-api-cluster"
}