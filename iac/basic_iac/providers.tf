provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "Creator"       = "Oleksandr Bukhanko"
      "Team"          = "people-info-api"
      "Product"       = "people-info-api"
      "Product-Group" = "people-info-api"
      "Environment"   = "qa"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "people-info-api"
    key     = "basic-iac/state"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
