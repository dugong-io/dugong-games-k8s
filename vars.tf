# Set the region that you want to use to host the factorio server and any other AWS-hosted infrastructure
variable "AWS_REGION" {    
    default = "eu-west-2"
}

# Set your home IP address for locking down the SSH admin traffic
variable "HOME_IP_ADDRESS" {
    type = list(string)
    default = ["81.107.87.136/32"]
}