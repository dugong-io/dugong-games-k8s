data "aws_s3_bucket_object" "cluster_endpoint" {
  bucket = "terraform-dugong-s3-outputs"
  key = "cluster_endpoint"
}

provider "helm" {
  kubernetes {
  host        = data.aws_s3_bucket_object.cluster_endpoint.body
  config_path = "~/.kube/config"
  }
  version = "~> 2.1.0"
}

provider "aws" {
    region = var.AWS_REGION
}