module "monitoring_hudi" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  output_format   = "hudi"
  module_name     = "hudi"
  database_name   = var.hudi_database_name
  table_name      = var.hudi_table_name
}

module "monitoring_json" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  output_format   = "json"
  module_name     = "json"
  database_name   = var.json_database_name
  table_name      = var.json_table_name
}
