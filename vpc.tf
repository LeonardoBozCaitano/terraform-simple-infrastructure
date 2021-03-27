resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_internet_gateway" "prod-internet-gateway" {
  vpc_id = aws_vpc.prod-vpc.id
}
