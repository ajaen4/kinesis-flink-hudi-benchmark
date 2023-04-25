module "monitoring" {

  source = "./monitoring"

  aws_region_name = "eu-west-1"
  aws_account_id = "482861842012"
  image_tag = "0.0.1"
  database_name = "hudi"
  table_name = "hudi_benchmark_ro"
}