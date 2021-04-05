output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# Store useful information in an s3 bucket that can be used by downstream modules
resource "aws_s3_bucket_object" "cluster_endpoint" {
    bucket = "terraform-dugong-s3-outputs"
    key = "cluster_endpoint"
    content = module.eks.cluster_endpoint
}

resource "aws_s3_bucket_object" "cluster_id" {
    bucket = "terraform-dugong-s3-outputs"
    key = "cluster_id"
    content = module.eks.cluster_id
}

resource "aws_s3_bucket_object" "cluster_oidc_provider" {
    bucket = "terraform-dugong-s3-outputs"
    key = "cluster_oidc_provider"
    content = module.eks.cluster_oidc_issuer_url
}

resource "aws_s3_bucket_object" "oidc_provider_arn" {
    bucket = "terraform-dugong-s3-outputs"
    key = "oidc_provider_arn"
    content = module.eks.oidc_provider_arn
}