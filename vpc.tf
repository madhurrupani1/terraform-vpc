# 1. Create a VPC e.g. roboshop
# 2. Create subnets e.g. public, private
# 3. Create route tables e.g. public, private and associate them
# 4. Create IGW e.g roboshop-igw and attach it to VPC created in Step 1
# 5. Create a route for IGW in Public route table
# 6. Create a NAT Gateway e.g. roboshop-nat in Public subnet and add a route in private route table

# 1. Create a VPC e.g. roboshop

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "roboshop-vpc"
  }
}
# 2. Create subnets e.g. public, private

# public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public"
  }
}

# private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private"
  }
}

# 3. Create route tables e.g. public, private and associate them

# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }
}

# private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private"
  }
}

# public route table association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# private route table association
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# 4. Create IGW e.g roboshop-igw and attach it to VPC created in Step 1

resource "aws_internet_gateway" "roboshop" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "roboshop"
  }
}

# 5. Create a route for IGW in Public route table

resource "aws_route" "gw" {
  gateway_id             = aws_internet_gateway.roboshop.id
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
}

# 6. Create a NAT Gateway e.g. roboshop-nat in Public subnet and add a route in private route table

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "roboshop" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.roboshop]
}

resource "aws_route" "nat" {
  gateway_id             = aws_nat_gateway.roboshop.id
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
}








