variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "artifacts_bucket_name" {
  description = "S3 bucket name for artifacts"
  type        = string
}

variable "source_stream_name" {
  description = "Kinesis Stream name for inbound data"
  type        = string
}

variable "glue_database_name" {
  description = "Glue Catalog database name"
  type        = string
}

variable "json_table_name" {
  description = "Athena json table"
  type        = string
}

variable "hudi_table_name" {
  description = "Athena hudi table"
  type        = string
}

variable "eks_tags" {
  description = "Tags to apply to EKS cluster resources"
  type        = map(string)
}

variable "eks_vpc_config" {
  description = "VPC configuration for EKS cluster"
  type = object({
    vpc_name                         = string
    cidr                             = string
    azs                              = list(string)
    private_subnets                  = list(string)
    public_subnets                   = list(string)
    enable_nat_gateway               = bool
    single_nat_gateway               = bool
    one_nat_gateway_per_az           = bool
    create_vpc                       = bool
    default_vpc_enable_dns_hostnames = bool
    default_vpc_enable_dns_support   = bool
    enable_flow_log                  = bool
    flow_log_destination_type        = string
    enable_dns_hostnames             = bool
    enable_dns_support               = bool
  })
}

variable "eks_kms_config" {
  description = "VPC configuration for EKS cluster"
  type = object({
    create_key              = bool
    deletion_window_in_days = number
    description             = string
    enable_key_rotation     = bool
    enabled                 = bool
    is_enabled              = bool
    key_usage               = string
    name                    = string
  })
}

variable "eks_config" {
  description = "EKS cluster configuration"
  type = object({
    cluster_endpoint_private_access = bool
    cluster_endpoint_public_access  = bool
    enable_irsa                     = bool
    attach_worker_cni_policy        = bool
    cluster_enabled_log_types       = list(string)

    worker_groups_core = object({
      name                 = string
      instance_type        = string
      additional_userdata  = string
      asg_desired_capacity = number
      asg_max_size         = number
      asg_min_size         = number
      kubelet_extra_args   = string
      suspended_processes  = list(string)
    })

    worker_groups_scaling = object({
      name                 = string
      instance_type        = string
      additional_userdata  = string
      asg_desired_capacity = number
      asg_max_size         = number
      asg_min_size         = number
      kubelet_extra_args   = string
      suspended_processes  = list(string)
    })
  })
}
