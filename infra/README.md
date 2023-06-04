<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.3.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.66.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | ./eks | n/a |
| <a name="module_kda_hudi_cow"></a> [kda\_hudi\_cow](#module\_kda\_hudi\_cow) | ./kda | n/a |
| <a name="module_kda_hudi_mor"></a> [kda\_hudi\_mor](#module\_kda\_hudi\_mor) | ./kda | n/a |
| <a name="module_kda_json"></a> [kda\_json](#module\_kda\_json) | ./kda | n/a |
| <a name="module_monitoring_hudi"></a> [monitoring\_hudi](#module\_monitoring\_hudi) | ./monitoring | n/a |
| <a name="module_monitoring_json"></a> [monitoring\_json](#module\_monitoring\_json) | ./monitoring | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_athena_workgroup.hudi_json_benchmark](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_glue_catalog_database.hudi_json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |
| [aws_glue_crawler.json_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler) | resource |
| [aws_iam_role.json_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kinesis_stream.inbound_kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_s3_bucket.flink_artifacts_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.flink_artifacts_s3_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.local_exec_mvn_package](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [archive_file.flink_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.glue_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | S3 bucket name for artifacts | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_eks_config"></a> [eks\_config](#input\_eks\_config) | EKS cluster configuration | <pre>object({<br>    cluster_endpoint_private_access = bool<br>    cluster_endpoint_public_access  = bool<br>    enable_irsa                     = bool<br>    attach_worker_cni_policy        = bool<br>    cluster_enabled_log_types       = list(string)<br><br>    worker_groups_core = object({<br>      name                 = string<br>      instance_type        = string<br>      additional_userdata  = string<br>      asg_desired_capacity = number<br>      asg_max_size         = number<br>      asg_min_size         = number<br>      kubelet_extra_args   = string<br>      suspended_processes  = list(string)<br>    })<br><br>    worker_groups_scaling = object({<br>      name                 = string<br>      instance_type        = string<br>      additional_userdata  = string<br>      asg_desired_capacity = number<br>      asg_max_size         = number<br>      asg_min_size         = number<br>      kubelet_extra_args   = string<br>      suspended_processes  = list(string)<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_eks_kms_config"></a> [eks\_kms\_config](#input\_eks\_kms\_config) | VPC configuration for EKS cluster | <pre>object({<br>    create_key              = bool<br>    deletion_window_in_days = number<br>    description             = string<br>    enable_key_rotation     = bool<br>    enabled                 = bool<br>    is_enabled              = bool<br>    key_usage               = string<br>    name                    = string<br>  })</pre> | n/a | yes |
| <a name="input_eks_tags"></a> [eks\_tags](#input\_eks\_tags) | Tags to apply to EKS cluster resources | `map(string)` | n/a | yes |
| <a name="input_eks_vpc_config"></a> [eks\_vpc\_config](#input\_eks\_vpc\_config) | VPC configuration for EKS cluster | <pre>object({<br>    vpc_name                         = string<br>    cidr                             = string<br>    azs                              = list(string)<br>    private_subnets                  = list(string)<br>    public_subnets                   = list(string)<br>    enable_nat_gateway               = bool<br>    single_nat_gateway               = bool<br>    one_nat_gateway_per_az           = bool<br>    create_vpc                       = bool<br>    default_vpc_enable_dns_hostnames = bool<br>    default_vpc_enable_dns_support   = bool<br>    enable_flow_log                  = bool<br>    flow_log_destination_type        = string<br>    enable_dns_hostnames             = bool<br>    enable_dns_support               = bool<br>  })</pre> | n/a | yes |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | Glue Catalog database name | `string` | n/a | yes |
| <a name="input_hudi_table_name"></a> [hudi\_table\_name](#input\_hudi\_table\_name) | Athena hudi table | `string` | n/a | yes |
| <a name="input_json_table_name"></a> [json\_table\_name](#input\_json\_table\_name) | Athena json table | `string` | n/a | yes |
| <a name="input_source_stream_name"></a> [source\_stream\_name](#input\_source\_stream\_name) | Kinesis Stream name for inbound data | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_dns"></a> [load\_balancer\_dns](#output\_load\_balancer\_dns) | The DNS name of the Load Balancer created by the Locust Helm chart |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
