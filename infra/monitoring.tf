module "monitoring_hudi" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  database_name   = "hudi"
  table_name      = "hudi_benchmark_ro"
}

module "monitoring_json" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  database_name   = "hudi"
  table_name      = "flink_output_json"
}
