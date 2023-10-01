terraform {
  backend "s3" {
    bucket = "OUTPUT_FROM_BOOTSTRAPER_TERRAFORM"
    key    = "kinesis-flink-hudi.tfstate"
    region = "eu-west-1"
  }
}
