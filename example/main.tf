provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source             = "geekbass/eks/aws"
  version            = "~> 0.0.1"
  cluster_name       = "my-eks-001"
  kubernetes_version = "1.17"

  # Workers
  desired_number_workers = 2
  min_number_workers     = 2
  max_number_workers     = 2
  instance_types         = "m5.2xlarge"
  availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  aws_profile            = ""

  tags = {
    owner      = "wbassler"
    expiration = "4h"
  }

  providers = {
    aws = aws
  }
}

// Create admin.conf local file to be used for kubectl
resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = "${path.module}/kubeconfig.conf"
}

output "config_map_aws_auth" {
  value = module.eks.config_map_aws_auth
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

