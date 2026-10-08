terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "sa-east-1"
}

provider "google" {
  project = "academic-demo-project"
  region  = "southamerica-east1"
}

module "branches" {
  source         = "../../modules/branch-stack"
  environment    = "staging"
  gcp_project_id = "academic-demo-project"
}
