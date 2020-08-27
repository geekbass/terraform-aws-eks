locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

// Kubeconfig output based on command using aws eks update-kubeconfig

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks.certificate_authority.0.data}
  name: ${join("", aws_eks_cluster.eks.*.arn)}
contexts:
- context:
    cluster: ${join("", aws_eks_cluster.eks.*.arn)}
    user: ${join("", aws_eks_cluster.eks.*.arn)}
  name: ${join("", aws_eks_cluster.eks.*.arn)}
current-context: ${join("", aws_eks_cluster.eks.*.arn)}
kind: Config
preferences: {}
users:
- name: ${join("", aws_eks_cluster.eks.*.arn)}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - us-east-1
      - eks
      - get-token
      - --cluster-name
      - ${join("", aws_eks_cluster.eks.*.id)}
      command: aws
      ${var.aws_profile != "" ? local.aws_profile : ""}
KUBECONFIG

// If AWS_PROFILE is supplied then add the environment variable
aws_profile = <<AWS_PROFILE
env:
      - name: AWS_PROFILE
        value: ${var.aws_profile}
AWS_PROFILE
}

output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = join("", aws_eks_cluster.eks.*.id)
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = join("", aws_eks_cluster.eks.*.arn)
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}