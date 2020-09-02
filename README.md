# Running an EKS with Terraform >= .12  
Please refer official [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) for more information about EKS.

NOTE: For a small cluster it will take anywhere from 10-15 minutes to complete initial creation.

Please refer to official [Terrform EKS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) docs for more information about the Terraform code.

Example:

```hcl
module "eks" {
    source = "geekbass/eks/aws"
    version = "~> 0.0.1"
    cluster_name   = "my-eks-001
    kubernetes_version = "1.17"

    # Workers
    desired_number_workers = 2
    min_number_workers     = 2
    max_number_workers     = 2
    instance_types         = "m5.2xlarge"
    }
```
### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) 12 or later
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Requirements

| Name | Version |
|------|---------|
| aws | >= 2.58 |
| random | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.58 |
| random | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_type | Desired AMI Type to Use. | `string` | `"AL2_x86_64"` | no |
| availability\_zones | List of AZs. | `list(string)` | `[]` | no |
| aws\_profile | Current AWS profile to use in Kubeconfig | `string` | `""` | no |
| cluster\_name | The name of your EKS Cluster. | `string` | `"my-eks"` | no |
| cluster\_name\_random\_string | Add a random string to the cluster name | `bool` | `false` | no |
| desired\_number\_workers | Desired Number of Worker Nodes. | `number` | `1` | no |
| disk\_size | Disk Size for Worker Nodes. | `number` | `20` | no |
| force\_update\_version | Whether to force an Upgrade if Pods are unable to be drained. | `bool` | `false` | no |
| instance\_types | Desired Instance Types for Worker Nodes. | `string` | `"t3.medium"` | no |
| kubernetes\_version | Desired Kuberenetes Version for the Cluster. This is used for Both Control Plane and Workers. | `string` | `"1.17"` | no |
| max\_number\_workers | Maximum Number of Worker Nodes. | `number` | `1` | no |
| min\_number\_workers | Minimum Number of Worker Nodes. | `number` | `1` | no |
| node\_group\_name | Node Group Name | `string` | `"eks"` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_kubeconfig | kubeconfig to use with AWS Auth |
| config\_map\_aws\_auth | n/a |
| eks\_cluster\_arn | The Amazon Resource Name (ARN) of the cluster |
| eks\_cluster\_id | The name of the cluster |
| kubeconfig | Default kubeconfig for kubectl |

