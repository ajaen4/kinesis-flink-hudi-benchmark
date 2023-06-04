variable "eks_tags" {
  type = map(string)
}

variable "aws_baseline_vpc" {
  type = any
}

variable "aws_baseline_kms" {
  type = map(string)
}

variable "aws_baseline_eks" {
  type = any
}
