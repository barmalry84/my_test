data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_security_group" "people_info_api_sg" {
  name        = "people-info-api-redis-sg"
  description = "Security group for Redis cluster"

  vpc_id      = data.aws_vpc.precreated_vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "people-info-api-redis-subnet-group"
  subnet_ids = tolist(data.aws_subnets.private.ids)
}

resource "aws_elasticache_cluster" "people_info_api_cluster" {
  cluster_id           = "people-info-api-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"

  security_group_ids   = [aws_security_group.people_info_api_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
}