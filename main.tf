/**
* # Running an EKS with Terraform >= .12
* Please refer official [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) for more information about EKS.
* 
* NOTE: For a small cluster it will take anywhere from 10-15 minutes to complete initial creation.
* 
* Please refer to official [Terrform EKS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) docs for more information about the Terraform code.
* 
* Example:
*
* ```hcl
* module "eks" {
*     source = "geekbass/eks/aws"
*     version = "~> 0.0.1"
*     cluster_name   = "my-eks-001
*     kubernetes_version = "1.17"
* 
*     # Workers
*     desired_number_workers = 2
*     min_number_workers     = 2
*     max_number_workers     = 2
*     instance_types         = "m5.2xlarge"
*     }
* ```
* ### Prerequisites
* - [Terraform](https://www.terraform.io/downloads.html) 12 or later
* - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
*/

provider "aws" {
  version = ">= 2.58"
}

provider "random" {
  version = ">= 2.0"
}

data "aws_region" "current" {}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.id
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.id
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = var.cluster_name
}

locals {
  cluster_name = var.cluster_name_random_string ? random_id.id.hex : var.cluster_name
}

resource "aws_eks_cluster" "eks" {
  name     = "${local.cluster_name}-eks-cluster"
  role_arn = aws_iam_role.eks-cluster.arn
  version  = var.kubernetes_version
  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = aws_subnet.eks[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.eks[*].id

  ami_type             = var.ami_type
  disk_size            = var.disk_size
  force_update_version = var.force_update_version
  instance_types       = [var.instance_types]

  scaling_config {
    desired_size = var.desired_number_workers
    max_size     = var.max_number_workers
    min_size     = var.min_number_workers
  }

  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

/*
EKS 
*/
resource "aws_iam_role" "eks-cluster" {
  name = "${local.cluster_name}-eks-cluster"
  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )
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

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster.name
}

/*
Worker
*/
resource "aws_iam_role" "eks-node" {
  name = "${local.cluster_name}-eks-node"
  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

resource "aws_security_group" "eks-cluster" {
  name        = "${local.cluster_name}-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }


  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )
}

resource "aws_security_group_rule" "eks-cluster-api" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster.id
  to_port           = 443
  type              = "ingress"
}

// if availability zones is not set request the available in this region
data "aws_availability_zones" "available" {
}

locals {
  availability_zones = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  subnet_range       = "10.0.128.0/18"
}

resource "aws_vpc" "eks" {
  cidr_block           = "10.0.128.0/18"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )
}

resource "aws_subnet" "eks" {
  count = length(local.availability_zones)

  availability_zone       = element(coalescelist(local.availability_zones, data.aws_availability_zones.available.names), count.index)
  cidr_block              = cidrsubnet(local.subnet_range, 4, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks.id

  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )
}

resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id

  tags = merge(
    var.tags,
    {
      "Name"                  = "${local.cluster_name}",
      "kubernetes.io/cluster" = "${local.cluster_name}",
    },
  )
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.eks.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks.id
}
