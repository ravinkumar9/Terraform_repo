terraform {
  backend "s3" {
    bucket  = "terraform-coding-excercise-bucket"
    key     = "ravin/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}