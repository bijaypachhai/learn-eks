# AWS Managed Kubernetes Service: Elastic Kubernetes Service (EKS)

```bash
## POLICIES TO ATTACH TO IAM USER/ROLE
aws eks list-access-policies
```

### EKS Access Entry

An access entry is an EKS resource attached to a specific cluster to control access. Access entries allow IAM principals (such as IAM roles) to authenticate to your cluster. You authorize each IAM principal to the permissions of the pre-made EKS access policies or your own Kubernetes RBAC groups.
