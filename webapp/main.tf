provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "mainVPC"{}

data "aws_availability_zones" "available" {
  state = "available"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
resource "aws_subnet" "publicSubnet" {
  vpc_id            = aws_default_vpc.mainVPC.id
  cidr_block        = "172.31.128.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]

}

# ec2

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "clo835_a1" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t3.micro"
  key_name = "clo835kp"
  subnet_id                   = aws_subnet.publicSubnet.id
  security_groups             = [aws_security_group.SG.id]
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"

  tags = {
    Name = "clo835_a1"
  }
}

# ecr

resource "aws_ecr_repository" "webapp-ecr" {
  name                 = "webapp-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "mysql-ecr" {
  name                 = "mysql-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# SecurityGroup to allow traffic for website
resource "aws_security_group" "SG" {
  name        = "Security-Group"
  description = "Allow all inbound HTTP traffic"
  vpc_id      = aws_default_vpc.mainVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
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
}