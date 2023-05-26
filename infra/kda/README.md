<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flink_hudi_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.flink_hudi_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_role.flink_app_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kinesisanalyticsv2_application.kinesisflink](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesisanalyticsv2_application) | resource |
| [aws_s3_bucket.output_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.artifacts_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_s3_object.code_location](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_object) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket"></a> [artifacts\_bucket](#input\_artifacts\_bucket) | Bucket name for output data | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-1"` | no |
| <a name="input_code_s3_key"></a> [code\_s3\_key](#input\_code\_s3\_key) | S3 key for Flink application packaged code | `string` | n/a | yes |
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | Glue Catalog database name | `string` | n/a | yes |
| <a name="input_hudi_table_type"></a> [hudi\_table\_type](#input\_hudi\_table\_type) | Hudi table type (MoR \| CoW) | `string` | `null` | no |
| <a name="input_kda_config"></a> [kda\_config](#input\_kda\_config) | Kinesis Data Analytics configuration | <pre>object(<br>    {<br>      runtime_environment           = string<br>      python                        = string<br>      jarfile                       = string<br>      parallelism                   = number<br>      parallelism_per_kpu           = number<br>      stream_inipos                 = string<br>      checkpoint_interval           = number<br>      min_pause_between_checkpoints = number<br>      log_level                     = string<br>      metrics_level                 = string<br>    }<br>  )</pre> | <pre>{<br>  "checkpoint_interval": 12000,<br>  "jarfile": "lib/combined.jar",<br>  "log_level": "INFO",<br>  "metrics_level": "TASK",<br>  "min_pause_between_checkpoints": 1000,<br>  "parallelism": 1,<br>  "parallelism_per_kpu": 1,<br>  "python": "flink_app.py",<br>  "runtime_environment": "FLINK-1_15",<br>  "stream_inipos": "LATEST"<br>}</pre> | no |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | Output format stored in S3 (hudi \| json \| print) | `string` | n/a | yes |
| <a name="input_source_stream_name"></a> [source\_stream\_name](#input\_source\_stream\_name) | Kinesis Stream name for source data | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_output_bucket"></a> [output\_bucket](#output\_output\_bucket) | n/a |
<!-- END_TF_DOCS -->
