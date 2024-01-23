resource "aws_iam_role" "people_info_api_ecs_role" {
  name = "people-info-api-ecs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "people_info_api_task_policy" {
  name        = "people-info-api-task-policy"
  description = "Allow access to dynamodb"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      Resource = aws_dynamodb_table.people_info.arn
      Effect   = "Allow",
    }]
  })
}

resource "aws_iam_policy" "people_info_api_cloudwatch_logging" {
  name        = "people-info-api-logging"
  description = "Send logs to CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.people_info_api_log_group.arn}:*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "people_info_api_ecs_ecr_pull" {
  name        = "people_info_api_ecr"
  description = "Permissions to ECR."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
        ],
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "people_info_api_ecs_ecr_pull_attachment" {
  policy_arn = aws_iam_policy.people_info_api_ecs_ecr_pull.arn
  role       = aws_iam_role.people_info_api_ecs_role.name
}

resource "aws_iam_role_policy_attachment" "people_info_api_task_attach" {
  policy_arn = aws_iam_policy.people_info_api_task_policy.arn
  role       = aws_iam_role.people_info_api_ecs_role.name
}

resource "aws_iam_role_policy_attachment" "people_info_api_ecs_task_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.people_info_api_ecs_role.name
}

resource "aws_iam_role_policy_attachment" "people_info_api_ecs_logging_attachment" {
  policy_arn = aws_iam_policy.people_info_api_cloudwatch_logging.arn
  role       = aws_iam_role.people_info_api_ecs_role.name
}
