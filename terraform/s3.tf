terraform {
  backend "s3" {
    bucket         = "sandeep-tfstate-buck"
    key            = "strapi/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" # optional but recommended
  }
}
