resource "aws_ecr_repository" "people_info_api" {
  name                 = local.ecr_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "people_info_api_cluster" {
  name = local.ecs_cluster_name
}