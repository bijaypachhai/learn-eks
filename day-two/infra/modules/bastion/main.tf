resource "aws_iam_role" "bastion_eks_role" {
  name = "bastion-eks-role"
  assume_role_policy = jsonencode({
	Version = "2012-10-17",
	Statement = [
		{
		Effect = "Allow",
		Principal = {
			Service = "ec2.amazonaws.com"
		},
		Action = "sts:AssumeRole"
	},
	]
  })
}

# resource "aws_iam_role_policy_attachment" "bastion_role_policy_attachment" {
#   role = aws_iam_role.bastion_eks_role.name
#   policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# }

# resource "aws_iam_instance_profile" "bastion_instance_profile" {
#   name = "bastion-instance-profile"
#   role = aws_iam_role.bastion_eks_role.name
# }

resource "aws_key_pair" "bastion_host_key" {
  key_name = "bastion_host_key.pub"
  public_key = "ssh-rsa mxxxxxGHs2xxxxxxOz4yxxxxxxxxx"
}

resource "aws_instance" "bastion_host" {
	subnet_id = var.subnet_id
	vpc_security_group_ids = [var.security_group_id]

	launch_template {
	  id = "lt-09de60217244ff0b1"
	  version = 1
	}

	associate_public_ip_address = true
	# iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
	instance_type = "t3.small"
	key_name = aws_key_pair.bastion_host_key.key_name
}

# resource "aws_eip" "bastion_host_eip" {
#   instance = aws_instance.bastion_host.id
#   domain   = "vpc"
# }