variable "cluster_name" {
  description = "The name of your EKS Cluster."
  default     = "my-eks"
}

variable "kubernetes_version" {
  description = "Desired Kuberenetes Version for the Cluster. This is used for Both Control Plane and Workers."
  default     = "1.17"
}

/*
Worker Node Group Documentation:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
*/

variable "node_group_name" {
  description = "Node Group Name"
  default     = "eks"
}

variable "desired_number_workers" {
  description = "Desired Number of Worker Nodes."
  default     = 1
}

variable "min_number_workers" {
  description = "Minimum Number of Worker Nodes."
  default     = 1
}

variable "max_number_workers" {
  description = "Maximum Number of Worker Nodes."
  default     = 1
}

variable "ami_type" {
  description = "Desired AMI Type to Use."
  default     = "AL2_x86_64"
}

variable "disk_size" {
  description = "Disk Size for Worker Nodes."
  default     = 20
}

variable "force_update_version" {
  description = "Whether to force an Upgrade if Pods are unable to be drained."
  default     = false
}

variable "instance_types" {
  description = "Desired Instance Types for Worker Nodes."
  default     = "t3.medium"
}

variable "availability_zones" {
  description = "List of AZs."
  type        = list(string)
  default     = []
}

variable "cluster_name_random_string" {
  description = "Add a random string to the cluster name"
  default     = false
}

variable "aws_profile" {
  description = "Current AWS profile to use in Kubeconfig"
  default     = ""
}