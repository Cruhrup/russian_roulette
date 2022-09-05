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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCudTcSat8rAzckBoORgs3kvbYghMNK4EtcEcGmWB07WXpDUNX5UPkfiumprEPCdZOWDIAco0CaCcHyIsmrLSKa2CahpwXihmwTrX4zOyqbPQBRvGlzKdtN8nQ1nDBVqVk7grj3Gbforqt1RNQcYoFE8aNHKuVc+EDo1sKR69W7JdUXz+rBIZl0q5Bkj3BYNXBTET1zL8+kMPBzdguzVh/UnIktKmFS9ZOapT9VwNNZ0M/OhjSqaGPox2eSw/+3yDTYeU3TmO+aCRsjNY6ZaNkvY5DpvO9MJf9Ue71hHqLBrtEWgCmLiQhXUUbyJfCHm8oB+bARcWf9j0XLL8nhbqz8c0urSn8hkH+mlsHBqkyntGSRCEIQWCfzA+8awFSyvYu08YBfOMwZx2YMWBsLOST5MUZNO/vSafFEgtizS4wXPPM0QCWYEmecbzbzfXOkXM6CWuecmoF6HcVHSSMLFrxmhN+zcUbWCAmZ4ORHFBdnPahzPmotsEBkHwt/o9GmDDr//Gz2jn6v/TjNcy2kMUzj0W+1aJNxgsYXZc0Z+O+OskVrMud6o6SP1uPXmTFLDhV3PFAOW6DuxC7IeXQnhlNlyMKIIqRe72NlABwug+6FXZdZXgbBZPeFgjAQMoGn9mluveJTUkeb4n7RFTmzI5Bwb9nVy+CmUkDIO8x8gj71Cw== guita@ELFASTOIII"
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