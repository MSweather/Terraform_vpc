terraform {
  backend "s3" {
    bucket = "abc-terraform" # Place where terraform state is stored
    key    = "uat/"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
  }

  required_version = "1.3.7"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  env      = "uat"
  cidr     = "662"
  region   = "us-east-1"
  customer = "client"
}


module "vpc" {
  source   = "../modules/vpc"
  customer = local.customer
  cidr     = local.cidr
  region   = local.region
}

