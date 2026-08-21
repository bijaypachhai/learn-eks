module "eks_vpc" {
  source = "./modules/vpc"
}

module "bastion_host" {
  source = "./modules/bastion"
  subnet_id = module.eks_vpc.public_subnets_id[0]
  security_group_id = module.eks_vpc.vpc_security_group_id
}

module "first_cluster" {
  source = "./modules/eks"
  subnet_ids = module.eks_vpc.private_subnets_id
  eks_admin_arn = module.bastion_host.eks_admin_arn
}