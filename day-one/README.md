# Day One Learn EKS

> [!Important]
> While creating NAT Gateway in Regional mode, separate public IPs are required for each availability zone. And if the cluster's API server is publicly accessible, then Managed Node Group in the private subnets require NAT Gateway to communicate with the Control Plane. Otherwise, EKS Managed Node Group cannot deploy successfully, throwing error: "Instances failed to join the kubernetes cluster"

```bash
terraform init -backend-config=./state.config

terraform plan

terraform apply
```
