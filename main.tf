#packer-hhtpd ami
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

locals {
  project_name = "EC2-Test"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
  default = "Please add your VPC id here"
}

variable "vpc_id" {
  type = string
}

data "aws_ami" "ami_id" {
  most_recent      = true
  owners           = ["self"]
    filter {
    name   = "name"
    values = ["my-server-httpd"]
  }
}

resource "aws_instance" "my_server" {
  ami           = data.aws_ami.ami_id.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_myserver.id]
  tags = {
    Name = "Server-Packer-httpd"
  }
}

output "public_ip_addrx" {
  value = aws_instance.my_server.public_ip

}


resource "aws_security_group" "sg_myserver" {
  name        = "launch-wizard-1"
  description = "myserver securitygroup"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}