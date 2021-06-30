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

  aws_kubeconfig = <<AWS_KUBECONFIG
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
AWS_KUBECONFIG

  // If AWS_PROFILE is supplied then add the environment variable
  aws_profile = <<AWS_PROFILE
env:
      - name: AWS_PROFILE
        value: ${var.aws_profile}
AWS_PROFILE

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${data.aws_eks_cluster.eks.certificate_authority[0].data}
    server: ${data.aws_eks_cluster.eks.endpoint}
  name: ${local.cluster_name}
contexts:
- context:
    cluster: ${local.cluster_name}
    user: kubernetes-admin
  name: kubernetes-admin@${local.cluster_name}
current-context: kubernetes-admin@${local.cluster_name}
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    token: ${data.aws_eks_cluster_auth.eks.token}
KUBECONFIG
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
  description = "Default kubeconfig for kubectl"
  value       = local.kubeconfig
}

output "aws_kubeconfig" {
  description = "kubeconfig to use with AWS Auth"
  value       = local.aws_kubeconfig
}

output "eks_node_groups" {
  value = aws_eks_node_group.eks

}
