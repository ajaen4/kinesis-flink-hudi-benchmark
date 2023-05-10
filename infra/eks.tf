module "eks" {

  source = "./eks"

  eks_tags         = var.eks_tags
  aws_baseline_vpc = var.eks_vpc_config
  aws_baseline_kms = var.eks_kms_config
  aws_baseline_eks = var.eks_config

}
