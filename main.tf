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
*     cluster_name   = "my-eks-001"
*     kubernetes_version = "1.19"
* 
*     # Workers
*     node_groups = {
*       label-studio = {
*           name = "label-studio"
*           desired_number_workers = 2
*            max_number_workers     = 2
*            min_number_workers     = 2
*
*            instance_types = ["t2.medium"]
*            ami_type  = "AL2_x86_64"
*            disk_size = 50
*            
*            k8s_labels = {
*                environment = "test"
*                app  = "label-studio"
*                owner   = "datascience"
*            }
*        },
*        ops = {
*            name = "ops"
*            desired_number_workers = 2
*            max_number_workers     = 2
*            min_number_workers     = 2
*
*            instance_types = ["t2.medium"]
*            ami_type  = "AL2_x86_64"
*            disk_size = 50
*
*            k8s_labels = {
*                environment = "test"
*                app  = "ops"
*                owner   = "datascience"
*            }
*        }
*    }
*     }
* ```
* ### Prerequisites
* - [Terraform](https://www.terraform.io/downloads.html) 12 or later
* - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
*/

provider "random" {}

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
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
    },
  )

  vpc_config {
    subnet_ids              = aws_subnet.eks[*].id
    public_access_cidrs     = var.admin_ips
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
    aws_vpc.eks
  ]
}

resource "aws_eks_node_group" "eks" {
  for_each = {
    for k, v in var.node_groups :
    k => v
  }

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.eks[*].id

  ami_type             = each.value.ami_type
  disk_size            = each.value.disk_size
  force_update_version = var.force_update_version
  instance_types       = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_number_workers
    max_size     = each.value.max_number_workers
    min_size     = each.value.min_number_workers
  }

  labels = merge(
    lookup(var.node_groups[each.key], "k8s_labels", {})
  )

  tags = merge(
    var.tags,
    {
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
    },
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
    aws_route_table_association.eks,
    aws_subnet.eks,
    aws_internet_gateway.eks
  ]
}

/*
EKS Default role for Cluster
*/
resource "aws_iam_role" "eks-cluster" {
  name = "${local.cluster_name}-eks-cluster"
  tags = merge(
    var.tags,
    {
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
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

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}

/*
Worker Default IAM role
*/
resource "aws_iam_role" "eks-node" {
  name = "${local.cluster_name}-eks-node"
  tags = merge(
    var.tags,
    {
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
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
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
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
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
    },
  )
}

resource "aws_route_table_association" "eks" {
  count = length(local.availability_zones)

  subnet_id      = element(aws_subnet.eks.*.id, count.index)
  route_table_id = aws_vpc.eks.main_route_table_id
}

resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id

  tags = merge(
    var.tags,
    {
      "Name"                  = local.cluster_name,
      "kubernetes.io/cluster" = local.cluster_name,
    },
  )
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.eks.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks.id
}
