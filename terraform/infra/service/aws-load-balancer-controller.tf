data "aws_s3_bucket_object" "cluster_oidc_provider" {
  bucket = "terraform-dugong-s3-outputs"
  key    = "cluster_oidc_provider"
}

data "aws_s3_bucket_object" "cluster_id" {
  bucket = "terraform-dugong-s3-outputs"
  key    = "cluster_id"
}

data "aws_s3_bucket_object" "vpc_id" {
  bucket = "terraform-dugong-s3-outputs"
  key    = "vpc_id"
}

locals {
	  clusterName                   = data.aws_s3_bucket_object.cluster_id.body
    cluster_oidc_issuer_url       = data.aws_s3_bucket_object.cluster_oidc_provider.body
    k8s_service_account_namespace = "kube-system"
    k8s_service_account_name      = "aws-load-balancer-controller"
    service_account_arn           = module.iam_assumable_role_admin.this_iam_role_arn
    vpc_id                        = data.aws_s3_bucket_object.vpc_id.body
}

# Deploy the AWS Load Balancer Controller
resource "helm_release" "aws-load-balancer-controller" {
    depends_on = [
      module.iam_assumable_role_admin
    ]
	name = "aws-load-balancer-controller"
	repository = "https://aws.github.io/eks-charts"
	chart = "aws-load-balancer-controller"
	namespace = "kube-system"
  
  values = [<<EOF
clusterName: ${local.clusterName}
region: ${var.AWS_REGION}
vpcId: ${local.vpc_id}
hostNetwork: true
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${local.service_account_arn}
EOF
  ]
}

# IAM roles
module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "aws-load-balancer-controller"
  provider_url                  = replace(local.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws-load-balancer-controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "aws-load-balancer-controller" {
  name_prefix = "aws-load-balancer-controller"
  description = "EKS aws-load-balancer-controller policy for cluster"
  policy      = data.aws_iam_policy_document.aws-load-balancer-controller.json
}

data "aws_iam_policy_document" "aws-load-balancer-controller" {
    source_json = file("iam-policy.json")
}