module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "192.170.0.0/20"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
    // Ensure to include additional required tags here
  }
}

# Create two public subnets in the same availability zone.
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.170.1.0/24"
  availability_zone = ""us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-1"
    // Include additional required tags here
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "192.170.2.0/24"
  availability_zone = ""us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-2"
    // Include additional required tags here
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
    // Include additional required tags here
  }
}

# Create a public route table and add a default route to the Internet Gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
    // Include additional required tags here
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}


# =========================
# Create your subnets here
# =========================
