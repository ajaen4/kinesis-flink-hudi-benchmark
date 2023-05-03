resource "aws_s3_bucket" "flink_artifacts_bucket" {
  bucket = var.artifacts_bucket_name

}

resource "null_resource" "local_exec_mvn_package" {
  triggers = {
    dependency_file = md5(file("${path.module}/../flink_app/pom.xml"))
  }
  provisioner "local-exec" {
    command = "cd .. && make uber-jar"
  }
}

data "archive_file" "flink_zip" {
  type        = "zip"
  source_dir  = "../flink_app"
  output_path = "../flink_app.zip"
  depends_on  = [null_resource.local_exec_mvn_package]
}

resource "aws_s3_object" "flink_artifacts_s3_key" {
  bucket = aws_s3_bucket.flink_artifacts_bucket.bucket
  key    = "${sha256(data.archive_file.flink_zip.output_base64sha256)}.zip"
  source = data.archive_file.flink_zip.output_path
}

