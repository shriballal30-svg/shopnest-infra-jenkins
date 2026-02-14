# ---------------- VPC ----------------
resource "aws_vpc" "shopnest_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "shopnest-vpc"
  }
}

# ---------------- Public Subnet ----------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.shopnest_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "shopnest-public-subnet"
  }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shopnest_vpc.id
}

# ---------------- Route Table ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.shopnest_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "shopnest_sg" {
  name   = "shopnest-sg"
  vpc_id = aws_vpc.shopnest_vpc.id

  # -----------------------------
  # SSH
  # -----------------------------
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # HTTP
  # -----------------------------
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Frontend
  # -----------------------------
  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Product Service
  # -----------------------------
  ingress {
    description = "Product Service"
    from_port   = 4001
    to_port     = 4001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # User Service
  # -----------------------------
  ingress {
    description = "User Service"
    from_port   = 4002
    to_port     = 4002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Cart Service
  # -----------------------------
  ingress {
    description = "Cart Service"
    from_port   = 4003
    to_port     = 4003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Notification Service
  # -----------------------------
  ingress {
    description = "Notification Service"
    from_port   = 4004
    to_port     = 4004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Python Service
  # -----------------------------
  ingress {
    description = "Python Service"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # PostgreSQL
  # -----------------------------
  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Redis
  # -----------------------------
  ingress {
    description = "Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # MongoDB
  # -----------------------------
  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Outbound
  # -----------------------------
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopnest-sg"
  }
}

# ---------------- EC2 ----------------
resource "aws_instance" "shopnest_ec2" {

  ami           = var.ami_id          # 🔥 Takes value from variables.tf
  instance_type = var.instance_type   # 🔥 From variables.tf
  key_name      = var.key_name        # 🔥 From variables.tf

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.shopnest_sg.id]
  
  # 🔥 INTERNAL STORAGE (ROOT DISK)
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install docker.io docker-compose git -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              newgrp docker
              EOF

  tags = {
    Name = "shopnest-ec2"
  }
}

