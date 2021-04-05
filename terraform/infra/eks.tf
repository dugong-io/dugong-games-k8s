module "eks" {
    source = "terraform-aws-modules/eks/aws"
    cluster_name = "dugong-cluster"
    cluster_version = "1.18"
    subnets = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id

    # Define the worker nodes
    node_groups = {
        base = {
            desired_capacity = 1
            max_capacity = 3
            min_capacity = 1
            instance_types = ["t3.medium",]
        }
    }
    workers_additional_policies = [aws_iam_policy.worker_policy.arn]

    # by default, the terraform module for eks tries to manage the eks cluster auth via aws but on windows we'll have to do this ourselves.
    manage_aws_auth=false

    # lock down public interface to my ip address
    cluster_endpoint_public_access_cidrs = [local.admin_ip.admin_ip_jon]
    cluster_endpoint_private_access = true
}

# Store useful information in an s3 bucket that can be used by downstream modules
resource "aws_s3_bucket_object" "cluster_endpoint" {
    bucket = "terraform-dugong-s3-outputs"
    key = "cluster_endpoint"
    content = module.eks.cluster_endpoint
}


# Deploy the EKS intgress controller