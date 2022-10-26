# AWS provider
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token

  assume_role {
    role_arn = var.aws_role_arn
  }
}
# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes
# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["--region", var.aws_region, "eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}

# Helm provider
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["--region", var.aws_region, "eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  #  cluster_name = "TF-TEST-DEV-tj-${random_string.suffix.result}"
  vpc_name     = "TF-tj"
  cluster_name = "TF-DEV-tj"

  common = {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      CreatedBy   = "taejune"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
