terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-1215"
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
