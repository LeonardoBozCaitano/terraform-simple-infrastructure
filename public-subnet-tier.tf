resource "aws_subnet" "public-prod-subnet" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.aws_used_availability_zone
  tags = {
    Name = "production"
    Type = "Public"
  }
}

resource "aws_route_table" "prod-vpc-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-internet-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.prod-internet-gateway.id
  }

  tags = {
    Name = "production"
  }
}

resource "aws_route_table_association" "public-prod-subet-association" {
  subnet_id      = aws_subnet.public-prod-subnet.id
  route_table_id = aws_route_table.prod-vpc-route-table.id
}

resource "aws_security_group" "allow-production-web-traffic" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "production-allow-web"
  }
}

resource "aws_network_interface" "production-web-server-ni" {
  subnet_id       = aws_subnet.public-prod-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-production-web-traffic.id]
}

resource "aws_eip" "web-elastic-ip" {
  vpc                       = true
  network_interface         = aws_network_interface.production-web-server-ni.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.prod-internet-gateway]
}

resource "aws_instance" "web-server" {
  ami = var.aws_ami
  instance_type = var.aws_instance_type
  availability_zone = var.aws_used_availability_zone
  key_name = "terraform_tests_key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.production-web-server-ni.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo this is your public server! > /var/www/html/index.html'
              EOF
  tags = {
    Name = "public-web-server"
  }
}