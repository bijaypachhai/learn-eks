variable "vpc_cidr" {
  type = string
  description = "CIDR Block for VPC"
  default = "10.2.0.0/16"
}

variable "vpc_region" {
  type = string
  description = "Region for AWS VPC"
  default = "ap-northeast-2"
}

variable "public_subnet_A_CIDR" {
  type = string
  description = "CIDR block for Subnet"
  default = "10.2.1.0/24"
} 

variable "public_subnet_B_CIDR" {
  type = string
  description = "CIDR block for subnet"
  default = "10.2.2.0/24"
}

variable "private_subnet_A_CIDR" {
  type = string
  description = "CIDR block for Subnet"
  default = "10.2.3.0/24"
}

variable "private_subnet_B_CIDR" {
  type = string
  description = "CIDR block for Subnet"
  default = "10.2.4.0/24"
}

variable "database_subnet_A_CIDR" {
  type = string
  description = "CIDR block for Subnet"
  default = "10.2.5.0/24"
}

variable "database_subnet_B_CIDR" {
  type = string
  description = "CIDR block for Subnet"
  default = "10.2.6.0/24"
}