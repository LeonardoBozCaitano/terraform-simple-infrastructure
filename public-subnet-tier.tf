resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.aws_used_availability_zone
  tags = {
    Name = "production"
    Type = "Public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.dev.id
  }

  tags = {
    Name = "production"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev.id

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
    Name = "production_allow_web"
  }
}

resource "aws_network_interface" "public1" {
  subnet_id       = aws_subnet.public1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.public.id]
}

resource "aws_eip" "this" {
  vpc                       = true
  network_interface         = aws_network_interface.public1.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.dev]
}

resource "aws_instance" "web_server" {
  ami = var.aws_ami
  instance_type = var.aws_instance_type
  availability_zone = var.aws_used_availability_zone
  key_name = "terraform_tests_key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.public1.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo this is your public server! > /var/www/html/index.html'
              EOF
  tags = {
    Name = "public_web_server"
  }
}