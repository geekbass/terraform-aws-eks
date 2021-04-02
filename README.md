# Running an EKS with Terraform >= .12
Please refer official [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) for more information about EKS.

NOTE: For a small cluster it will take anywhere from 10-15 minutes to complete initial creation.

Please refer to official [Terrform EKS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) docs for more information about the Terraform code.

Example:

```hcl
module "eks" {
    source = "geekbass/eks/aws"
    version = "~> 0.0.1"
    cluster_name   = "my-eks-001"
    kubernetes_version = "1.19"

    # Workers
    node_groups = {
      label-studio = {
          name = "label-studio"
          desired_number_workers = 2
           max_number_workers     = 2
           min_number_workers     = 2

           instance_types = ["t2.medium"]
           ami_type  = "AL2_x86_64"
           disk_size = 50

           k8s_labels = {
               environment = "test"
               app  = "label-studio"
               owner   = "datascience"
           }
       },
       ops = {
           name = "ops"
           desired_number_workers = 2
           max_number_workers     = 2
           min_number_workers     = 2

           instance_types = ["t2.medium"]
           ami_type  = "AL2_x86_64"
           disk_size = 50

           k8s_labels = {
               environment = "test"
               app  = "ops"
               owner   = "datascience"
           }
       }
   }
    }
```
### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) 12 or later
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.eks-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks-node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.internet_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table_association.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ips"></a> [admin\_ips](#input\_admin\_ips) | List of IPs that can access API. | `list(any)` | <pre>[<br>  "0.0.0.0/32"<br>]</pre> | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | Desired AMI Type to Use. | `string` | `"AL2_x86_64"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of AZs. | `list(string)` | `[]` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Current AWS profile to use in Kubeconfig | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of your EKS Cluster. | `string` | `"my-eks"` | no |
| <a name="input_cluster_name_random_string"></a> [cluster\_name\_random\_string](#input\_cluster\_name\_random\_string) | Add a random string to the cluster name | `bool` | `false` | no |
| <a name="input_desired_number_workers"></a> [desired\_number\_workers](#input\_desired\_number\_workers) | Desired Number of Worker Nodes. | `number` | `1` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk Size for Worker Nodes. | `number` | `20` | no |
| <a name="input_force_update_version"></a> [force\_update\_version](#input\_force\_update\_version) | Whether to force an Upgrade if Pods are unable to be drained. | `bool` | `false` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | Desired Instance Types for Worker Nodes. | `string` | `"t3.medium"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Desired Kuberenetes Version for the Cluster. This is used for Both Control Plane and Workers. | `string` | `"1.17"` | no |
| <a name="input_max_number_workers"></a> [max\_number\_workers](#input\_max\_number\_workers) | Maximum Number of Worker Nodes. | `number` | `1` | no |
| <a name="input_min_number_workers"></a> [min\_number\_workers](#input\_min\_number\_workers) | Minimum Number of Worker Nodes. | `number` | `1` | no |
| <a name="input_node_group_name"></a> [node\_group\_name](#input\_node\_group\_name) | Node Group Name | `string` | `"eks"` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Map of maps of eks node groups to create. | `any` | <pre>{<br>  "example": {<br>    "ami_type": "AL2_x86_64",<br>    "desired_number_workers": 2,<br>    "disk_size": 50,<br>    "instance_types": [<br>      "t2.medium"<br>    ],<br>    "k8s_labels": {<br>      "environment": "example",<br>      "name": "example"<br>    },<br>    "max_number_workers": 2,<br>    "min_number_workers": 2,<br>    "name": "example"<br>  }<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_kubeconfig"></a> [aws\_kubeconfig](#output\_aws\_kubeconfig) | kubeconfig to use with AWS Auth |
| <a name="output_config_map_aws_auth"></a> [config\_map\_aws\_auth](#output\_config\_map\_aws\_auth) | n/a |
| <a name="output_eks_cluster_arn"></a> [eks\_cluster\_arn](#output\_eks\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | The name of the cluster |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Default kubeconfig for kubectl |
