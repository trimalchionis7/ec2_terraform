# Create a VPC to launch our instances into
resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "jonnie-vpc"
  }
}

# Create two public subnets in different AZs
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[0]
  availability_zone       = var.az[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[1]
  availability_zone       = var.az[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-2"
  }
}

# Create two private subnets in different AZs
resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[0]
  availability_zone = var.az[0]

  tags = {
    Name = "private-1"
  }
}
resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = var.az[1]

  tags = {
    Name = "private-2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "igw_jonnie-vpc"
  }
}

/*
# Create NAT gateway in public subnet 1
resource "aws_nat_gateway" "nat-gw" {
  count         = 1
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id     = aws_subnet.public-1.id

  tags = {
    Name = "nat-gw"
  }
}

# Create Elastic IP for NAT gateway
resource "aws_eip" "nat-eip" {
  vpc = true

  tags = {
    Name = "nat-eip"
  }
}

*/

# Create public & private route tables
resource "aws_route_table" "RB_Public_RouteTable" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "RB_Private_RouteTable" {
  vpc_id = aws_vpc.dev_vpc.id

  /*route {
    # cidr_block = "0.0.0.0/0"
    # gateway_id = aws_nat_gateway.nat-gw[0].id
  }
  */

  tags = {
    Name = "private-rt"
  }
}

# Associate public & private route tables with subnets
resource "aws_route_table_association" "Public_Subnet1_Asso" {
  route_table_id = aws_route_table.RB_Public_RouteTable.id
  subnet_id      = aws_subnet.public-1.id
  depends_on     = [aws_route_table.RB_Public_RouteTable, aws_subnet.public-1]
}

resource "aws_route_table_association" "Public_Subnet2_Asso" {
  route_table_id = aws_route_table.RB_Public_RouteTable.id
  subnet_id      = aws_subnet.public-2.id
  depends_on     = [aws_route_table.RB_Public_RouteTable, aws_subnet.public-2]
}

resource "aws_route_table_association" "Private_Subnet1_Asso" {
  route_table_id = aws_route_table.RB_Private_RouteTable.id
  subnet_id      = aws_subnet.private-1.id
  depends_on     = [aws_route_table.RB_Private_RouteTable, aws_subnet.private-1]
}
resource "aws_route_table_association" "Private_Subnet2_Asso" {
  route_table_id = aws_route_table.RB_Private_RouteTable.id
  subnet_id      = aws_subnet.private-2.id
  depends_on     = [aws_route_table.RB_Private_RouteTable, aws_subnet.private-2]
}

# Create security group for RDS database
resource "aws_security_group" "allow_ec2_mysql" {
  name        = "allow_ec2_mysql"
  description = "Allow mysql inbound traffic from ec2"
  vpc_id      = aws_vpc.dev_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "rds-sg"
  }
}