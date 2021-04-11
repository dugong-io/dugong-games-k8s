module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    cluster_name    = "dugong-cluster"
    cluster_version = "1.19"
    vpc_id          = module.vpc.vpc_id
    subnets         = module.vpc.private_subnets

    # Define the worker nodes
    node_groups = {
        private    = {
            desired_capacity = 1
            max_capacity     = 3
            min_capacity     = 1
            instance_types   = ["t3.medium",]
            capacity_type    = "SPOT"
            subnets          = module.vpc.private_subnets
            k8s_labels       = map("subnet", "private")
        }
        public    = {
            desired_capacity = 1
            max_capacity     = 3
            min_capacity     = 1
            instance_types   = ["t3.medium",]
            capacity_type    = "SPOT"
            subnets          = module.vpc.public_subnets
            k8s_labels       = map("subnet", "public")
        }
    }

    # by default, the terraform module for eks tries to manage the eks cluster auth via aws but on windows we'll have to do this ourselves.
    manage_aws_auth=false

    # lock down public interface to my ip address
    cluster_endpoint_public_access_cidrs = [local.admin_ip.admin_ip_jon]
    cluster_endpoint_private_access = true

    # oidc config
    enable_irsa = true
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
    content_type = "text/plain"

}

resource "aws_s3_bucket_object" "cluster_oidc_provider" {
    bucket = "terraform-dugong-s3-outputs"
    key = "cluster_oidc_provider"
    content = module.eks.cluster_oidc_issuer_url
    content_type = "text/plain"
}

resource "aws_s3_bucket_object" "oidc_provider_arn" {
    bucket = "terraform-dugong-s3-outputs"
    key = "oidc_provider_arn"
    content = module.eks.oidc_provider_arn
}

# get official iam policy for aws alb ingress controller
# Note: change the version to the desire version
data "http" "worker_policy" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.8/docs/examples/iam-policy.json"

    request_headers = {
        Accept = "application/json"
    }
}

# and attach it
resource "aws_iam_role_policy" "worker_policy" {
  name   = "worker_policy"
  role   = module.eks.worker_iam_role_name
  policy = data.http.worker_policy.body
}

# install EBS Controller

data "aws_eks_cluster" "name" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "name" {
  name = module.eks.cluster_id
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.name.identity[0].oidc[0].issuer
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.name.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.name.token
  load_config_file       = false
  version                = "~> 1.11.4"
}

module "ebs_csi_driver_controller" {
    depends_on = [
      module.eks
    ]
  source = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "2.4.0"

  ebs_csi_controller_role_name               = "ebs-csi-driver-controller"
  ebs_csi_controller_role_policy_name_prefix = "ebs-csi-driver-policy"
  oidc_url                                   = module.eks.cluster_oidc_issuer_url
}