terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.38.0"
    }
  }

backend "s3" {
  bucket = "remote-statefile" 
  key  = "firewalls"   
  region = "us-east-1"        
  dynamodb_table = "statefile-lock"
}

}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}