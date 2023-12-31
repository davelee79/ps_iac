terraform {
  required_version = ">= 1.0.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.49"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.16.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.5.1"
    }
  }
  #backend "s3" {
  #  bucket = "dave-terraform-2022"
  #  key    = "terraform.tfstate"
  #  region = "us-east-1"
  #}

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "terraform-ssp-github-actions-state"
  #   region = "us-west-2"
  #   key    = "e2e/eks-cluster-with-new-vpc/terraform.tfstate"
  # }
}
