provider "aws" {
  profile = "practica-hudi-flink"
  region     = var.AWS_REGION
  #assume_role {
  #  role_arn    = "arn:aws:iam::482861842012:role/practicahudiflink"
  #}
}
