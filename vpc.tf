# Build the VPC
resource "aws_vpc" "dugong-hosting-vpc" {
    cidr_block           = "10.0.0.0/22"
    instance_tenancy     = "default"
    enable_dns_hostnames = true
    
    tags = {
        Name = "dugong-hosting"
    }
}

# Set DHCP options for the VPC
resource "aws_vpc_dhcp_options" "dugong-hosting-dhcp" {
    domain_name         = "eu-west-2.compute.internal"
    domain_name_servers = [ "AmazonProvidedDNS" ]
}

# Associate DHCP options with the VPC
resource "aws_vpc_dhcp_options_association" "dugong-hosting-dhcp-association" {
    vpc_id          = aws_vpc.dugong-hosting-vpc.id
    dhcp_options_id = aws_vpc_dhcp_options.dugong-hosting-dhcp.id
}


# Figure out which availability zones are available

data "aws_availability_zones" "available" {
    state = "available"
}

# Add three private subnets and three public subnets
# This could be improved by running the resource once for public and once for private, than running it 6 times.
resource "aws_subnet" "privateA" {
    vpc_id            = aws_vpc.dugong-hosting-vpc.id
    cidr_block        = "10.0.0.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        Name = "privateA"
        project = "dugong-hosting"
    }
}

resource "aws_subnet" "privateB" {
    vpc_id            = aws_vpc.dugong-hosting-vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        Name    = "privateB"
        project = "dugong-hosting"
    }
}

resource "aws_subnet" "privateC" {
    vpc_id            = aws_vpc.dugong-hosting-vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = data.aws_availability_zones.available.names[2]

    tags = {
        Name    = "privateC"
        project = "dugong-hosting"
    }
}

resource "aws_subnet" "publicA" {
    vpc_id                  = aws_vpc.dugong-hosting-vpc.id
    cidr_block              = "10.0.3.0/26"
    availability_zone       = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    
    tags = {
        Name    = "publicA"
        project = "dugong-hosting"
    }
}

resource "aws_subnet" "publicB" {
    vpc_id                  = aws_vpc.dugong-hosting-vpc.id
    cidr_block              = "10.0.3.64/26"
    availability_zone       = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = true
    
    tags = {
        Name    = "publicB"
        project = "dugong-hosting"
    }
}

resource "aws_subnet" "publicC" {
    vpc_id                  = aws_vpc.dugong-hosting-vpc.id
    cidr_block              = "10.0.3.128/26"
    availability_zone       = data.aws_availability_zones.available.names[2]
    map_public_ip_on_launch = true
    
    tags = {
        Name = "publicC"
        project = "dugong-hosting"
    }
}

# Add an internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.dugong-hosting-vpc.id

    tags = {
        Name    = "igw"
        project = "dugong-hosting"
    }
}

# Create the route tables for the public subnets
resource "aws_route_table" "publicA" {
  vpc_id = aws_vpc.dugong-hosting-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id  
    }

    tags = {
      Name    = "publicARouteTable"
      project = "dugong-hosting"
    }
}

resource "aws_route_table" "publicB" {
  vpc_id = aws_vpc.dugong-hosting-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id  
    }

    tags = {
      Name    = "publicBRouteTable"
      project = "dugong-hosting"
    }
}

resource "aws_route_table" "publicC" {
  vpc_id = aws_vpc.dugong-hosting-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id  
    }

    tags = {
      Name    = "publicCRouteTable"
      project = "dugong-hosting"
    }
}

resource "aws_route_table" "privateA" {
  vpc_id = aws_vpc.dugong-hosting-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngwA.id  
    }

    tags = {
      Name    = "privateARouteTable"
      project = "dugong-hosting"
    }
}

resource "aws_route_table" "privateB" {
  vpc_id = aws_vpc.dugong-hosting-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngwB.id  
    }

    tags = {
      Name    = "privateBRouteTable"
      project = "dugong-hosting"
    }
}

resource "aws_route_table" "privateC" {
  vpc_id = aws_vpc.dugong-hosting-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.ngwC.id  
    }

    tags = {
      Name    = "privateCRouteTable"
      project = "dugong-hosting"
    }
}

# Associate the public subnets with the new route table created above
# This could be improved by making it look up any subnets with the name public and putting them in one at a time.
resource "aws_route_table_association" "publicA" {
    subnet_id      = aws_subnet.publicA.id
    route_table_id = aws_route_table.publicA.id
}

resource "aws_route_table_association" "publicB" {
    subnet_id      = aws_subnet.publicB.id
    route_table_id = aws_route_table.publicB.id
}

resource "aws_route_table_association" "publicC" {
    subnet_id      = aws_subnet.publicC.id
    route_table_id = aws_route_table.publicC.id
}

resource "aws_route_table_association" "privateA" {
    subnet_id      = aws_subnet.privateA.id
    route_table_id = aws_route_table.privateA.id
}

resource "aws_route_table_association" "privateB" {
    subnet_id      = aws_subnet.privateB.id
    route_table_id = aws_route_table.privateB.id
}

resource "aws_route_table_association" "privateC" {
    subnet_id      = aws_subnet.privateC.id
    route_table_id = aws_route_table.privateC.id
}

# Provision the eips in each subnet for the NAT gateways to use later on
resource "aws_eip" "publicA" {
    vpc = true
}

resource "aws_eip" "publicB" {
    vpc = true
}

resource "aws_eip" "publicC" {
    vpc = true
}

# Create NAT Gateways in each of the public subnets for the private subnets to access the internet
resource "aws_nat_gateway" "ngwA" {
    allocation_id = aws_eip.publicA.id
    subnet_id     = aws_subnet.publicA.id

    tags = {
        Name    = "ngwA"
        project = "dugong-hosting"
    }
}

resource "aws_nat_gateway" "ngwB" {
    allocation_id = aws_eip.publicB.id
    subnet_id     = aws_subnet.publicB.id

    tags = {
        Name    = "ngwB"
        project = "dugong-hosting"
    }
}

resource "aws_nat_gateway" "ngwC" {
    allocation_id = aws_eip.publicC.id
    subnet_id     = aws_subnet.publicC.id

    tags = {
        Name    = "ngwC"
        project = "dugong-hosting"
    }
}

# Create Security Group for web traffic inbound
resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow permitted web traffic in"
  vpc_id      = aws_vpc.dugong-hosting-vpc.id

  ingress {
      description = "HTTP traffic in from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group for admin access to instances
resource "aws_security_group" "admin" {
  name        = "admin"
  description = "Allow permitted admin traffic in"
  vpc_id      = aws_vpc.dugong-hosting-vpc.id

  ingress {
      description = "PING traffic in from my home IP"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["81.107.87.136/32"]
  }

  ingress {
      description = "SSH traffic in from my home IP"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["81.107.87.136/32"] ## CHANGE THIS BEFORE PUSHING TO GITHUB ## 
  }
}

# Get the subnet ids
data "aws_subnet_ids" "dugong-hosting-subnets" {
    vpc_id = aws_vpc.dugong-hosting-vpc.id

    depends_on = [
      aws_subnet.publicA,
      aws_subnet.publicB,
      aws_subnet.publicC,
      aws_subnet.privateA,
      aws_subnet.privateB,
      aws_subnet.privateC,
    ]
}