module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> v2.0"

    # VPC naming
    name = "dugong-hosting-vpc"
    cidr = "10.0.0.0/22"

    # Set DHCP options for the VPC
    dhcp_options_domain_name         = "eu-west-2.compute.internal"
    dhcp_options_domain_name_servers = [ "AmazonProvidedDNS" ]
    enable_dns_hostnames             = true    

    # Subnets
    azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.3.0/26", "10.0.3.64/26", "10.0.3.128/26"]

     public_subnet_tags = {
        "kubernetes.io/cluster/dugong-cluster" = "shared"
        "kubernetes.io/role/elb"                      = "1"
     }

    private_subnet_tags = {
        "kubernetes.io/cluster/dugong-cluster" = "shared"
        "kubernetes.io/role/internal-elb"             = "1"
     }

    # NAT Gateways
    enable_nat_gateway     = true
    single_nat_gateway     = false
    one_nat_gateway_per_az = false

    # Internet Gateway
    create_egress_only_igw = true
}