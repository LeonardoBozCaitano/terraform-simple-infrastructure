resource "aws_subnet" "private-prod-subnet" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "production"
    Type = "private"
  }
}

resource "aws_route_table" "prod-private-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
  }

  tags = {
    Name = "production"
  }
}

resource "aws_route_table_association" "private-prod-subnet-association" {
  subnet_id      = aws_subnet.private-prod-subnet.id
  route_table_id = aws_route_table.prod-private-route-table.id
}

resource "aws_security_group" "allow-app-tear-traffic" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

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
    Name = "production-allow-app-tier"
  }
}

resource "aws_network_interface" "production-app-server-ni" {
  subnet_id       = aws_subnet.private-prod-subnet.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.allow-app-tear-traffic.id]
}

resource "aws_instance" "app-server" {
  ami = "ami-0bd91caaa9bc42cf3"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "terraform_tests_key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.production-app-server-ni.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo this is your private server! > /var/www/html/index.html'
              EOF
  tags = {
    Name = "private-app-server"
  }
}