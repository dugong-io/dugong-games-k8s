module "ssh_security_group" {
    source = "terraform-aws-modules/security-group/aws"
    version = "~> v3.0"

    name = "admin_access"
    description = "ping and ssh permitted from admin IP address"
    vpc_id = module.vpc.vpc_id

    ingress_with_cidr_blocks = [
        {
            from_port = -1
            to_port = -1
            protocol = "icmp"
            description = "ping"
            cidr_blocks = "81.107.87.136/32"
        }
    ]
}