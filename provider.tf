terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }

  backend "s3" { // todo: Dynamic
    // here you will put bucket name where will save terraform state, this bucket already should exists
    bucket = "BUCKET NAME"
    // here will put object name into bucket s3
    key    = "OBJECT NAME" 
    // here will put AWS region
    region = "us-west-1"
    // here will put profile name configured with AWS cli
    profile = "ezops" 
  }
}

provider "aws" { // todo: Dynamic
  // here will put profile name configured with AWS cli
  profile = "ezops"
  region  = var.region
}
