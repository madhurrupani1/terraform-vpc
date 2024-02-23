terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0" # Use a version constraint to allow any version >= 3.0
    }
  }
}
provider "aws" {
  region = "us-east-1"
}