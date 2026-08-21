output "eks_admin_arn" {
  value = aws_iam_role.bastion_eks_role.arn
  description = "ARN of the IAM Role with Admin Access To EKS Cluster"
}