terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }

  backend "s3" { // todo: Dynamic
    bucket = "beta-test-infra" 
    key    = "codox/terraform.tfstate" 
    region = "us-west-1" 
    dynamodb_table = "test-codox" 
    profile = "ezops" 
  }
}

provider "aws" { // todo: Dynamic
  profile = "ezops"
  region  = var.region
}
