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

  # Backend remoto (S3 / GCS) documentado en docs/academic y docs/architecture.
  # Se deja en "local" a proposito: este proyecto no cuenta con credenciales
  # cloud, por lo que nunca se ejecuta `terraform apply` real contra AWS/GCP
  # (ver FASE IV - Terraform State del enunciado).
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
  environment    = "production"
  gcp_project_id = "academic-demo-project"
}
