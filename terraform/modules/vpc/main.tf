variable "customer" {
  type = string
}

variable "cidr" {
  type = string
}

variable region {
  type = string
}


resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.${var.cidr}.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    client = var.customer
    Name   = "${var.customer}-VPC"
    source = "Terraform"
  }
}


resource "aws_subnet" "pub1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.${var.cidr}.0.0/22"
  availability_zone = "${var.region}a"
  tags              = {
    Network = "Public",
    client  = var.customer,
    Name    = "${var.customer}-VPC-pub1-${var.region}a"
    source  = "Terraform"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.${var.cidr}.16.0/22"
  availability_zone = "${var.region}b"
  tags              = {
    Network = "Public",
    client  = var.customer,
    Name    = "${var.customer}-VPC-pub2-${var.region}b"
    source  = "Terraform"
  }
}


resource "aws_subnet" "db1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.${var.cidr}.12.0/22"
  availability_zone = "${var.region}d"
  tags              = {
    Network = "Private",
    client  = var.customer,
    Name    = "${var.customer}-VPC-db1-${var.region}d"
    source  = "Terraform"
  }
}

resource "aws_subnet" "db2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.${var.cidr}.28.0/22"
  availability_zone = "${var.region}d"
  tags              = {
    Network = "Private",
    client  = var.customer,
    Name    = "${var.customer}-VPC-db2-${var.region}d"
    source  = "Terraform"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    client = var.customer,
    Name   = "${var.customer}-Igw"
    source = "Terraform"
  }
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  tags       = {
    client = var.customer,
    Name   = "${var.customer}-Ngw"
    source = "Terraform"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1.id

  tags = {
    client = var.customer,
    Name   = "${var.customer}-Ngw"
    source = "Terraform"
  }
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "pub-rt-1" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name    = "${var.customer}-VPC-pub-rt-1"
    client  = var.customer
    Network = "Public"
    source  = "Terraform"
  }
}

resource "aws_route_table" "pub-rt-2" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name    = "${var.customer}-VPC-pub-rt-2"
    client  = var.customer
    Network = "Public"
    source  = "Terraform"
  }
}


resource "aws_route_table" "db-rt-1" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name    = "${var.customer}-VPC-db-rt-1"
    client  = var.customer
    Network = "Private"
    source  = "Terraform"
  }
}

resource "aws_route_table" "db-rt-2" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name    = "${var.customer}-VPC-db-rt-2"
    client  = var.customer
    Network = "Private"
    source  = "Terraform"
  }
}


resource "aws_route_table_association" "pub-sub-1-rt-assn" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub-rt-1.id
}

resource "aws_route_table_association" "pub-sub-2-rt-assn" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.pub-rt-2.id
}


resource "aws_route_table_association" "db-sub-1-rt-assn" {
  subnet_id      = aws_subnet.db1.id
  route_table_id = aws_route_table.db-rt-1.id
}

resource "aws_route_table_association" "db-sub-2-rt-assn" {
  subnet_id      = aws_subnet.db2.id
  route_table_id = aws_route_table.db-rt-2.id
}
