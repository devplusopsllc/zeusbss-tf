provider "aws" {
  region = "us-east-1" # Change this to your desired region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical's owner ID
}

resource "aws_network_interface" "build_base" {
  subnet_id       = "subnet-0eee484eb419a7f44" # Replace with your subnet ID
  security_groups = ["sg-0986c7c6fadeb126c"] # Replace with your security group ID

}

resource "aws_instance" "build_base" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name      = "buildbase" # Replace with your key pair name

network_interface {
    network_interface_id = aws_network_interface.build_base.id
    device_index        = 0
  }
  tags = {
    Name = "build-base"
  }

  
}

resource "aws_security_group" "buildbase_sg" {
  name        = "buildbase-sg"
  description = "buildbase security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open SSH to the world
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

