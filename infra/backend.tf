terraform {
    backend "s3" {
        bucket = "euw1-bluetab-general-tfstate-pro"
        key = "kinesis-flink-hudi-2.tfstate"
        region = "eu-west-1"
        profile = "practica_cloud"
    }
}
