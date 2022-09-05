terraform {
    required_providers {
        aws = {}
        random = {}
    }
    required_version = ">= 1.0.0"
}

provider "aws" {
    region  = "us-east-1"
    profile = "PROFILE_NAME_HERE"
}

provider "random" {}

resource "random_pet" "name" {
  length    = 3
  prefix    = "the"
}

resource "aws_internet_gateway" "omega-igw" {}

resource "aws_internet_gateway_attachment" "omega-igwa" {
    internet_gateway_id = aws_internet_gateway.omega-igw.id
    vpc_id              = aws_vpc.omega.id
}

resource "aws_route_table" "omega-rt" {
    vpc_id = aws_vpc.omega.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.omega-igw.id
    }

    tags = {
        Name = "omega-rt"
    }
}

resource "aws_main_route_table_association" "omega-rt-main" {
    vpc_id         = aws_vpc.omega.id
    route_table_id = aws_route_table.omega-rt.id 
}

resource "aws_vpc" "omega" {
    cidr_block           = "10.1.0.0/16"
    enable_dns_hostnames = true
    
    tags = {
        Name = "omega"
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
    name        = "ssh_access_only"
    description = "allow ssh ingress from anywhere"
    vpc_id      = aws_vpc.omega.id

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow ssh only from anywhere"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
    }
    egress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow any/any egress"
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
}

resource "aws_key_pair" "ssh-key" {
    key_name   = "aws_ssh_key"
    public_key = "MY_KEY.PUB HERE"
}

resource "aws_instance" "basic_ec2_instance" {
    ami                         = "ami-05fa00d4c63e32376"
    instance_type               = "t2.micro"
    user_data                   = file("init-script.sh")
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.ssh_only.id]
    subnet_id                   = aws_subnet.main.id
    key_name                    = "aws_ssh_key"

    tags = {
        Name = random_pet.name.id
    }
}