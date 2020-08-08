terraform {
  required_version = "~> 0.12.29"
  required_providers {
    aws = "~> 3.0.0"
  }

  backend "s3" {
    bucket               = "ecs-resource-exp20200805231011812600000001"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "environment"
    region               = "ap-northeast-1"
  }
}
