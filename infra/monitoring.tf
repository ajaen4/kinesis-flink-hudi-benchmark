module "monitoring_hudi" {

  source = "./monitoring"

  aws_region_name = "eu-west-1"
  aws_account_id = "482861842012"
  image_tag = "0.0.1"
  database_name = "hudi"
  table_name = "hudi_benchmark_ro"
  output_format = "hudi"
}

module "monitoring_json" {

  source = "./monitoring"

  aws_region_name = "eu-west-1"
  aws_account_id = "482861842012"
  image_tag = "0.0.1"
  database_name = "hudi"
  table_name = "flink_output_json"
  output_format = "json"
}