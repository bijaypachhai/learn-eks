output "vpc_id" {
  value = aws_vpc.eks_vpc.id
  description = "The ID of eks-VPC"
}

output "public_subnets_id" {
  value = [aws_subnet.eks_public_subnet_A.id, aws_subnet.eks_public_subnet_B.id]
  description = "List of public Subnets Id"
}

output "private_subnets_id" {
  value = [aws_subnet.eks_private_subnet_A.id, aws_subnet.eks_private_subnet_B.id]
  description = "List of Private Subnets Id"
}

output "database_subnets_id" {
  value = [aws_subnet.eks_database_subnet_A.id, aws_subnet.eks_database_subnet_B.id]
  description = "List of Database Subnets Id"
}

output "vpc_security_group_id" {
  value = aws_security_group.eks_vpc_sg.id
  description = "Security Group ID of the VPC"
}