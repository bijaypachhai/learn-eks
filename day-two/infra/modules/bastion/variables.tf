variable "subnet_id" {
  type = string
  description = "ID of the Subnet to deploy the bastion host"
}

variable "security_group_id" {
  type = string
  description = "ID of the Security Group of the VPC"
}