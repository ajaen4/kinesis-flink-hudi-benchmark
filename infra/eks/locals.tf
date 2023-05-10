locals {
  name            = "cluster-${var.eks_tags.project}-${var.eks_tags.environment}"
  cluster_version = "1.24"
  region          = data.aws_region.current.name
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
