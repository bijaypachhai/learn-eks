data "aws_iam_role" "cluster_role" {
  name = "AmazonEKSClusterRole"
}

data "aws_iam_role" "node_role" {
  name = "AmazonEKSNodeRole"
}


resource "aws_eks_cluster" "first_eks_cluster" {
  name = "modern-jazz-mushrooms"

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = data.aws_iam_role.cluster_role.arn
  version  = "1.34"

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access = false
  }
}

resource "aws_eks_node_group" "first_eks_ng" {
  cluster_name    = aws_eks_cluster.first_eks_cluster.name
  node_group_name = "first-eks-ng"

  version         = aws_eks_cluster.first_eks_cluster.version

  node_role_arn   = data.aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  instance_types = ["c7i-flex.large", "t3.small"]

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }

  remote_access {
    ec2_ssh_key = "bastion_host_key.pub"
  }

  # timeouts {
  #   create = "15m"
  # }
}

resource "aws_eks_access_entry" "first_eks_access_entry" {
  cluster_name      = aws_eks_cluster.first_eks_cluster.name
  principal_arn     = var.eks_admin_arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "first_eks_access_policy_association" {
  cluster_name  = aws_eks_cluster.first_eks_cluster.name

  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.eks_admin_arn

  access_scope {
    type       = "cluster"
  }
}