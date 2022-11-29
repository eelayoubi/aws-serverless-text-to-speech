terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Owner       = "Terraform"
      Project     = "audio_posts"
    }
  }
}