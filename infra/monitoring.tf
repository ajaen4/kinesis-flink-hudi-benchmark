module "monitoring_hudi_mor" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  output_format   = "hudi_mor"
  module_name     = "hudi"
  database_name   = var.glue_database_name
  table_name      = var.hudi_mor_table_name
}

module "monitoring_hudi_cow" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  output_format   = "hudi_cow"
  module_name     = "hudi"
  database_name   = var.glue_database_name
  table_name      = var.hudi_cow_table_name
}

module "monitoring_json" {

  source = "./monitoring"

  aws_region_name = var.aws_region
  aws_account_id  = data.aws_caller_identity.current.account_id
  image_tag       = "0.0.1"
  output_format   = "json"
  module_name     = "json"
  database_name   = var.glue_database_name
  table_name      = var.json_table_name
}
