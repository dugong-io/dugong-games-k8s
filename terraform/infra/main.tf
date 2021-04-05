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

# Create the aws_iam_policy for the workers to use to manage the ALB
resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "worker policy for managing the ALB"
  policy      = file("iam-policy.json")
}