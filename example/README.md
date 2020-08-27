# EKS How To

### EKS Deploy Cluster
1) Take the `./main.tf` and copy it locally.

2) Make changes to the variables as you see fit.

3) Initialize Terraform.
```
terraform init
```

4) Auth to AWS.

5) Run apply.
```
terraform plan -out plan.out
terraform apply plan.out
```

### Using with Kubectl
An `admin.conf` will be created locally that be used to authenticate against the cluster. This uses the Role and/or `AWS_PROFILE` associated with what you define in you credentials.

```
export KUBECONFIG=admin.conf

kubectl get cluster-info

```
### EKS Destroy
1) Run destroy.
```
terraform destroy
```