data "aws_iam_role" "cluster_role" {
  name = "AmazonEKSClusterRole"
}

data "aws_iam_role" "node_role" {
  name = "AmazonEKSNodeRole"
}


resource "aws_eks_cluster" "first_eks_cluster" {
  name = ""

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = data.aws_iam_role.cluster_role.arn
  version  = "1.34"

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_node_group" "first_eks_ng" {
  cluster_name    = aws_eks_cluster.first_eks_cluster.name
  node_group_name = "first-eks-ng"

  version         = aws_eks_cluster.first_eks_cluster.version

  node_role_arn   = data.aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  instance_types = ["t3.small", "c7i-flex.large"]

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }
}