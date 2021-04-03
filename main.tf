## Create an IAM role for the EKS cluster
resource "aws_iam_role" "dugong-hosting-ekscluster-iam-role" {
  name = "dugong-hosting-ekscluster-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

## Create and attach the EKSCluster IAM policy for the eks cluster to the eks iam role
resource "aws_iam_role_policy_attachment" "dugong-hosting-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.dugong-hosting-ekscluster-iam-role.name
}

## Create and attach the VPC Resource IAM policy for the eks cluster to the eks iam role
resource "aws_iam_role_policy_attachment" "dugong-hosting-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.dugong-hosting-ekscluster-iam-role.name
}


## Create EKS cluster

resource "aws_eks_cluster" "dugong-hosting-ekscluster" {
    name     = "dugong-hosting-ekscluster"
    role_arn = aws_iam_role.dugong-hosting-ekscluster-iam-role.arn
    version  = 1.18

    vpc_config {
      subnet_ids              = [
        aws_subnet.publicA.id,
        aws_subnet.publicB.id,
        aws_subnet.publicC.id,
        aws_subnet.privateA.id,
        aws_subnet.privateB.id,
        aws_subnet.privateC.id,
      ]
      endpoint_private_access = true
      endpoint_public_access  = true
      public_access_cidrs = [ "81.107.87.136/32" ]
    }

    depends_on = [
      aws_iam_role_policy_attachment.dugong-hosting-AmazonEKSClusterPolicy,
      aws_iam_role_policy_attachment.dugong-hosting-AmazonEKSVPCResourceController,
    ]

    tags = {
        Name    = "eks-cluster"
        project = "dugong-hosting"
    }
}

## Are these required here?
#output "endpoint" {
#    value = aws_eks_cluster.dugong-hosting-ekscluster.endpoint
#}

#output "kubeconfig-certificate-authority-data" {
#  value = aws_eks_cluster.dugong-hosting-ekscluster.certificate_authority[0].data
#}

## Create the IAM roles and policies for the eks cluster nodes used below
resource "aws_iam_role" "dugong-hosting-eksnodes-iam-role" {
  name = "eks-node-group-dugong-hosting-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "dugong-hosting-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.dugong-hosting-eksnodes-iam-role.name
}

resource "aws_iam_role_policy_attachment" "dugong-hosting-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.dugong-hosting-eksnodes-iam-role.name
}

resource "aws_iam_role_policy_attachment" "dugong-hosting-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.dugong-hosting-eksnodes-iam-role.name
}


## Create the eks node group for the ec2 instances in the cluster

resource "aws_eks_node_group" "dugong-hosting-eksnodegroup" {
  cluster_name    = aws_eks_cluster.dugong-hosting-ekscluster.name
  node_group_name = "dugong-hosting-eksnodegroup"
  node_role_arn   = aws_iam_role.dugong-hosting-eksnodes-iam-role.arn
  subnet_ids      = data.aws_subnet_ids.dugong-hosting-subnets.ids
  capacity_type   = "SPOT"
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size = 3
    min_size = 1
  }

  timeouts {
      create = "15m"
      update = "15m"
      delete = "15m"
  }

  depends_on = [
    aws_iam_role_policy_attachment.dugong-hosting-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.dugong-hosting-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.dugong-hosting-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "dugong-hosting-eks-nodes"
    project = "dugong-hosting"
  }

  remote_access {
    ec2_ssh_key = "terraforma"
  }
}


##

## Create a security group for communication into the fargate cluster
#resource "aws_security_group" "dugong-hosting-app" {
#  name = "dugong-hosting-app"
#  description = "Allow permitted factorio traffic in"
#  vpc_id = aws_vpc.dugong-hosting-vpc.id

#  ingress {
#      description = "Factorio-app traffic in from anywhere"
#      from_port = 34197
#      to_port = 34197
#      protocol = "udp"
#      cidr_blocks = ["0.0.0.0/0"]
#  }

#  ingress {
#      description = "Ping traffic in from anywhere"
#      from_port = -1
#      to_port = -1
#      protocol = "icmp"
#      cidr_blocks = ["0.0.0.0/0"]
#  }
#}
