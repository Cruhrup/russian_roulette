terraform {
    required_providers {
        aws = {}
        random = {}
    }
    required_version = ">= 1.0.0"
}

provider "aws" {
    region  = "us-east-1"
    profile = "terraform"
}

provider "random" {}

resource "random_pet" "name" {
  length    = 4
  prefix    = "the"
}

resource "aws_vpc" "omega" {
    cidr_block = "10.1.0.0/16"
    
    tags = {
        Name = "main"
    }
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.omega.id
    cidr_block = "10.1.1.0/24"

    tags = {
        Name = "main"
    }
}

resource "aws_security_group" "ssh_only" {
    name        = "ssh_only"
    description = "allow ssh only from anywhere"
    vpc_id      = aws_vpc.omega.id

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow ssh only from anywhere"
        from_port   = 22
        protocol    = "tcp"
        to_port     = 22
    }       
}

resource "aws_instance" "testme01" {
    ami                         = "ami-05fa00d4c63e32376"
    instance_type               = "t2.micro"
    user_data                   = file("init-script.sh")
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.ssh_only.id]
    subnet_id                   = aws_subnet.main.id

    tags = {
        Name = random_pet.name.id
    }
}