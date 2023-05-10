locals {

  private_subnet_az1_id   = [module.aws_baseline_vpc.private_subnets[0]]
  private_subnet_az1_name = "az1"

  private_subnet_az2_id   = [module.aws_baseline_vpc.private_subnets[1]]
  private_subnet_az2_name = "az2"

  private_subnet_az3_id   = [module.aws_baseline_vpc.private_subnets[2]]
  private_subnet_az3_name = "az3"

  worker_groups_core_tags = [
    {
      "key"                 = "k8s.io/cluster-autoscaler/enabled"
      "propagate_at_launch" = "true"
      "value"               = "false"
    },
    {
      "key"                 = "k8s.io/cluster-autoscaler/${local.name}"
      "propagate_at_launch" = "true"
      "value"               = "owned"
    },
    {
      "key"                 = "node-type"
      "propagate_at_launch" = "true"
      "value"               = "core"
    }
  ]

  worker_groups_scaling_tags = [
    {
      "key"                 = "k8s.io/cluster-autoscaler/enabled"
      "propagate_at_launch" = "true"
      "value"               = "false"
    },
    {
      "key"                 = "node-type"
      "propagate_at_launch" = "true"
      "value"               = "core-scaling"
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.23.0"

  # see locals.tf
  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id  = module.aws_baseline_vpc.vpc_id
  subnets = module.aws_baseline_vpc.private_subnets

  cluster_endpoint_private_access      = var.aws_baseline_eks.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.aws_baseline_eks.cluster_endpoint_public_access
  cluster_enabled_log_types            = var.aws_baseline_eks.cluster_enabled_log_types
  enable_irsa                          = var.aws_baseline_eks.enable_irsa
  attach_worker_cni_policy             = var.aws_baseline_eks.attach_worker_cni_policy
  worker_additional_security_group_ids = [module.sg_eks_worker_group_all.this_security_group_id]
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy",
    "arn:aws:iam::aws:policy/AmazonKinesisFullAccess",
    "arn:aws:iam::aws:policy/AmazonKinesisAnalyticsFullAccess"
  ]

  worker_groups_launch_template = [
    {
      name                          = "${var.aws_baseline_eks.worker_groups_core.name}-${local.private_subnet_az1_name}"
      subnets                       = local.private_subnet_az1_id
      instance_type                 = var.aws_baseline_eks.worker_groups_core.instance_type
      additional_userdata           = var.aws_baseline_eks.worker_groups_core.additional_userdata
      asg_desired_capacity          = var.aws_baseline_eks.worker_groups_core.asg_desired_capacity
      asg_max_size                  = var.aws_baseline_eks.worker_groups_core.asg_max_size
      asg_min_size                  = var.aws_baseline_eks.worker_groups_core.asg_min_size
      kubelet_extra_args            = var.aws_baseline_eks.worker_groups_core.kubelet_extra_args
      suspended_processes           = var.aws_baseline_eks.worker_groups_core.suspended_processes
      additional_security_group_ids = [module.sg_eks_worker_group_on_demand.this_security_group_id]
      tags                          = local.worker_groups_core_tags
    },
    {
      name                          = "${var.aws_baseline_eks.worker_groups_core.name}-${local.private_subnet_az2_name}"
      subnets                       = local.private_subnet_az2_id
      instance_type                 = var.aws_baseline_eks.worker_groups_core.instance_type
      additional_userdata           = var.aws_baseline_eks.worker_groups_core.additional_userdata
      asg_desired_capacity          = var.aws_baseline_eks.worker_groups_core.asg_desired_capacity
      asg_max_size                  = var.aws_baseline_eks.worker_groups_core.asg_max_size
      asg_min_size                  = var.aws_baseline_eks.worker_groups_core.asg_min_size
      kubelet_extra_args            = var.aws_baseline_eks.worker_groups_core.kubelet_extra_args
      suspended_processes           = var.aws_baseline_eks.worker_groups_core.suspended_processes
      additional_security_group_ids = [module.sg_eks_worker_group_on_demand.this_security_group_id]
      tags                          = local.worker_groups_core_tags
    },
    {
      name                          = "${var.aws_baseline_eks.worker_groups_core.name}-${local.private_subnet_az3_name}"
      subnets                       = local.private_subnet_az3_id
      instance_type                 = var.aws_baseline_eks.worker_groups_core.instance_type
      additional_userdata           = var.aws_baseline_eks.worker_groups_core.additional_userdata
      asg_desired_capacity          = var.aws_baseline_eks.worker_groups_core.asg_desired_capacity
      asg_max_size                  = var.aws_baseline_eks.worker_groups_core.asg_max_size
      asg_min_size                  = var.aws_baseline_eks.worker_groups_core.asg_min_size
      kubelet_extra_args            = var.aws_baseline_eks.worker_groups_core.kubelet_extra_args
      suspended_processes           = var.aws_baseline_eks.worker_groups_core.suspended_processes
      additional_security_group_ids = [module.sg_eks_worker_group_on_demand.this_security_group_id]
      tags                          = local.worker_groups_core_tags
    },
    {
      name                          = "${var.aws_baseline_eks.worker_groups_scaling.name}-${local.private_subnet_az1_name}"
      subnets                       = local.private_subnet_az1_id
      instance_type                 = var.aws_baseline_eks.worker_groups_scaling.instance_type
      additional_userdata           = var.aws_baseline_eks.worker_groups_scaling.additional_userdata
      asg_desired_capacity          = var.aws_baseline_eks.worker_groups_scaling.asg_desired_capacity
      asg_max_size                  = var.aws_baseline_eks.worker_groups_scaling.asg_max_size
      asg_min_size                  = var.aws_baseline_eks.worker_groups_scaling.asg_min_size
      kubelet_extra_args            = var.aws_baseline_eks.worker_groups_scaling.kubelet_extra_args
      suspended_processes           = var.aws_baseline_eks.worker_groups_scaling.suspended_processes
      additional_security_group_ids = [module.sg_eks_worker_group_on_demand.this_security_group_id]
      tags                          = local.worker_groups_scaling_tags
    },
    {
      name                          = "${var.aws_baseline_eks.worker_groups_scaling.name}-${local.private_subnet_az2_name}"
      subnets                       = local.private_subnet_az2_id
      instance_type                 = var.aws_baseline_eks.worker_groups_scaling.instance_type
      additional_userdata           = var.aws_baseline_eks.worker_groups_scaling.additional_userdata
      asg_desired_capacity          = var.aws_baseline_eks.worker_groups_scaling.asg_desired_capacity
      asg_max_size                  = var.aws_baseline_eks.worker_groups_scaling.asg_max_size
      asg_min_size                  = var.aws_baseline_eks.worker_groups_scaling.asg_min_size
      kubelet_extra_args            = var.aws_baseline_eks.worker_groups_scaling.kubelet_extra_args
      suspended_processes           = var.aws_baseline_eks.worker_groups_scaling.suspended_processes
      additional_security_group_ids = [module.sg_eks_worker_group_on_demand.this_security_group_id]
      tags                          = local.worker_groups_scaling_tags
    },
    {
      name                          = "${var.aws_baseline_eks.worker_groups_scaling.name}-${local.private_subnet_az3_name}"
      subnets                       = local.private_subnet_az3_id
      instance_type                 = var.aws_baseline_eks.worker_groups_scaling.instance_type
      additional_userdata           = var.aws_baseline_eks.worker_groups_scaling.additional_userdata
      asg_desired_capacity          = var.aws_baseline_eks.worker_groups_scaling.asg_desired_capacity
      asg_max_size                  = var.aws_baseline_eks.worker_groups_scaling.asg_max_size
      asg_min_size                  = var.aws_baseline_eks.worker_groups_scaling.asg_min_size
      kubelet_extra_args            = var.aws_baseline_eks.worker_groups_scaling.kubelet_extra_args
      suspended_processes           = var.aws_baseline_eks.worker_groups_scaling.suspended_processes
      additional_security_group_ids = [module.sg_eks_worker_group_on_demand.this_security_group_id]
      tags                          = local.worker_groups_scaling_tags
    },
  ]

  tags = var.eks_tags

  depends_on = [
    module.sg_eks_worker_group_on_demand,
    module.sg_eks_worker_group_spot,
    module.sg_eks_worker_group_all
  ]
}

resource "aws_eks_addon" "aws_eks_addon_csi" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.14.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  depends_on = [
    module.eks
  ]
}

resource "aws_eks_addon" "aws_eks_addon_cni" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = "v1.12.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  depends_on = [
    module.eks
  ]
}

module "sg_eks_worker_group_on_demand" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "3.2.0"
  name                = "sg_eks_worker_group_on_demand"
  description         = "Security group for eks worker group"
  vpc_id              = module.aws_baseline_vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags         = var.eks_tags
}

module "sg_eks_worker_group_spot" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "3.2.0"
  name                = "sg_eks_worker_group_spot"
  description         = "Security group for eks worker group"
  vpc_id              = module.aws_baseline_vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags         = var.eks_tags
}

module "sg_eks_worker_group_locust" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "3.2.0"
  name                = "sg_eks_worker_group_locust"
  description         = "Security group for eks worker group locust_low_cpu"
  vpc_id              = module.aws_baseline_vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags         = var.eks_tags
}

module "sg_eks_worker_group_all" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "3.2.0"
  name                = "sg_eks_worker_group_all"
  description         = "Security group for eks worker group"
  vpc_id              = module.aws_baseline_vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags         = var.eks_tags
}
