resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "production"
    Type = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev.id

  route {
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "production"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "private" {
  name        = "allow_public_subnet"
  description = "Allow inbound traffic from the other subnet"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "production_allow_app_tier"
  }
}

resource "aws_eip" "nat" {
  depends_on = [
    aws_internet_gateway.dev
  ]
  vpc   = true
}

resource "aws_nat_gateway" "gw" {
  depends_on = [
    aws_eip.nat
  ]
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private1.id
  tags = {
    Name = "dev"
  }
}

resource "aws_network_interface" "private1" {
  subnet_id       = aws_subnet.private1.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.private.id]
}

resource "aws_instance" "app_server" {
  ami = var.aws_ami
  instance_type = var.aws_instance_type
  availability_zone = var.aws_used_availability_zone
  key_name = "terraform_tests_key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.private1.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo this is your private server! > /var/www/html/index.html'
              EOF
  tags = {
    Name = "private_app_server"
  }
}