# Set terraform to use remote state
terraform {
  backend "s3" {
    bucket         = "terraform-dugong-game-k8s-state-infra"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-dugong-game-k8s-locks-infra"
    encrypt        = true
  }
}