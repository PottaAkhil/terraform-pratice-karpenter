terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
    }
  }
   
  backend "s3" {
    bucket = "akhil-matsons"
    key    = "new/statefile"
    #dynamodb_table = "Dynamo"
    region = "us-east-1"
    encrypt        = true
    profile = "matson"
  }
}

provider "aws" {
  shared_credentials_files = ["C:/Users/Akhil/.aws/credentials"]
  profile                 = "matson"
}

