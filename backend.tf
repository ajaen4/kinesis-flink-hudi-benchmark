terraform {
    backend "s3" {
        bucket = "euw1-bluetab-general-tfstate-pro"
        key = "kinesis-flink-hudi.tfstate"
        region = "eu-west-1"
        profile = "practica-hudi-flink"
    }
}
