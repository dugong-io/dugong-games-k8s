# Set the region that you want to use to host the AWS-hosted infrastructure
variable "AWS_REGION" {    
    default = "eu-west-2"
}

# Get secrets from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "admin_ip" {
    secret_id = "admin_ip"
}

locals {
    admin_ip = jsondecode (
        data.aws_secretsmanager_secret_version.admin_ip.secret_string
    )
}