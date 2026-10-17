terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.48.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "roboshop-s3-statefiles"
    key     = "70-acm.tfstate"
    region  = "us-east-1"
    encrypt = true

    # Modern Native S3 Locking (Terraform v1.10.0+)
    use_lockfile = true

  }
}

provider "aws" {
  region = "us-east-1"
}
