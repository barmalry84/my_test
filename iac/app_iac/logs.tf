resource "aws_cloudwatch_log_group" "people_info_api_log_group" {
  name              = "/ecs/people-info-api"
  retention_in_days = 30
}