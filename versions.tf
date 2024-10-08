terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas",
      version = "1.21.0"
    }

  }
}

provider "aws" {
    region =  "eu-north-1"
}