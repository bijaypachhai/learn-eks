module "eks_vpc" {
  source = "./modules/vpc"
  eip_allocation_id_a = ""
  eip_allocation_id_b = ""
}

module "first_cluster" {
  source = "./modules/eks"
  subnet_ids = module.eks_vpc.private_subnets_id
}