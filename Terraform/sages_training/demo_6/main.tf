provider "aws" {
 region = "us-west-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-mikolajjjj"

  tags = {
    Name        = "My bucket"
    Environment = "dev"
  }
}

resource "random_string" "random_filename" {
  length  = 10
  special = false
}

resource "random_string" "random_content" {
  length  = 10
  special = false
}

resource "local_file" "random_file" {
  depends_on = [
    random_string.random_filename,
    random_string.random_content,
  ]

  filename = "${random_string.random_filename.result}.txt"
  content  = "${random_string.random_content.result}"
}

resource "aws_s3_bucket_object" "random_file" {
  depends_on = [
    local_file.random_file,
  ]

  bucket = aws_s3_bucket.b.id
  key    = local_file.random_file.filename
  source = local_file.random_file.filename
}
