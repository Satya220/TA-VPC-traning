resource "aws_vpc" "lab_vpc" {
  cidr_block = var.vpc_cidr


tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = var.cidr_public

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = var.cidr_private

  tags = {
    Name = "private_subnet"
  }
}
resource "aws_subnet" "data" {
  for_each = var.cidr_data
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = each.value
  availability_zone = join("", [var.aws_region, each.key] )

  tags = {
    Name = join("", ["data-", each.key])
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "gateway"
  }
}

resource "aws_eip" "lb" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}