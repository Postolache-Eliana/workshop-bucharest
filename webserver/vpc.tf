# VPC - Virtual Private Cloud, a virtual network dedicated to your AWS account
resource "aws_vpc" "webserver" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "webserver-vpc"
  }
}

# Public Subnets - one for each availability zone
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.webserver.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.webserver.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.webserver.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-c"
  }
}

# Security group - a virtual firewall that controls inbound and outbound traffic
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.webserver.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# Internet Gateway - allows instances to access the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webserver.id

  tags = {
    Name = "main-igw"
  }
}

# Route Table - defines the routes for the VPC
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.webserver.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main-rt"
  }
}

# Route Table Association - associates the route table with the public subnets
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.rt.id
}
