terraform {
  backend "s3" {
    bucket         = "phoenix-tf-state-segun-2026"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}