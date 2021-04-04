provider "aws" {
    region = var.AWS_REGION
}

provider "helm" {
  kubernetes {
  host                   = module.eks.cluster_endpoint
  config_path = "./kubeconfig_dugong-cluster"
  }
  version = "~> 2.1.0"
}