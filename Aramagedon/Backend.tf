terraform {
  backend "s3" {
    bucket = "bucketsetup4ado"
    key = "BasicLinux2"
    region = "us-east-1"
  }
}
