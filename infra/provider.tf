provider "aws" {
  profile = "practica_cloud"
  region  = var.aws_region
}

provider "kubernetes" {
  host                   = "https://${aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
