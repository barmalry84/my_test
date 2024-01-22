provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "Creator"       = "Oleksandr Bukhanko"
      "Team"          = "simple-nodejs-api"
      "Product"       = "simple-nodejs-api"
      "Product-Group" = "simple-nodejs-api"
      "Environment"   = "qa"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "people-info-api"
    key     = "app-iac/state"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
