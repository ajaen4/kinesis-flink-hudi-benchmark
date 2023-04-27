tags = {
  terraform   = "true"
  environment = "dev"
  project     = "locust-on-aws-eks"
  region      = "eu-west-1"
}

aws_baseline_vpc = {
  vpc_name                         = "locust-on-aws-eks"
  cidr                             = "10.1.0.0/16"
  azs                              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets                  = ["10.1.0.0/20", "10.1.16.0/20", "10.1.32.0/20"]
  public_subnets                   = ["10.1.48.0/20", "10.1.64.0/20", "10.1.80.0/20"]
  enable_nat_gateway               = true
  single_nat_gateway               = true
  one_nat_gateway_per_az           = false
  create_vpc                       = true
  default_vpc_enable_dns_hostnames = true
  default_vpc_enable_dns_support   = true
  enable_flow_log                  = true
  flow_log_destination_type        = "s3"
  enable_dns_hostnames             = true
  enable_dns_support               = true
}


aws_baseline_kms = {
  create_key              = true
  deletion_window_in_days = 7
  description             = "KMS key to encrypt objects inside s3 bucket logging"
  enable_key_rotation     = true
  enabled                 = true
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  name                    = "s3-logging"
}
aws_baseline_eks = {
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  attach_worker_cni_policy        = true
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  worker_groups_core_name                 = "core-group-on-demand"
  worker_groups_core_instance_type        = "m5.xlarge"
  worker_groups_core_additional_userdata  = ""
  worker_groups_core_asg_desired_capacity = 1
  worker_groups_core_asg_max_size         = 10
  worker_groups_core_asg_min_size         = 1
  worker_groups_core_kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=ondemand,node-type=core"
  worker_groups_core_suspended_processes  = ["AZRebalance"]

  worker_groups_core_scaling_name                 = "core-scaling-group-on-demand"
  worker_groups_core_scaling_instance_type        = "m6a.2xlarge"
  worker_groups_core_scaling_additional_userdata  = ""
  worker_groups_core_scaling_asg_desired_capacity = 1
  worker_groups_core_scaling_asg_max_size         = 3
  worker_groups_core_scaling_asg_min_size         = 1
  worker_groups_core_scaling_kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=ondemand,node-type=core-scaling"
  worker_groups_core_scaling_suspended_processes  = ["AZRebalance"]
}
