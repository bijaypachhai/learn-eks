# variable "cluster_role_arn" {
#   type = string
#   description = "ARN of Cluster IAM Role: required by control plane to make API calls to AWS"
# }

variable "subnet_ids" {
  type = list(string)
  description = "List of Subnet IDs to deploy worker nodes"
}