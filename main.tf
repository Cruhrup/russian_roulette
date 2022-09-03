terraform {
    required_version = ">= 1.0.0"
}

provider "aws" {
    region = "us-east-1"
    profile = "terraform"
}

resource "aws_vpc" "omega" {
    cidr_block = "10.1.0.0/16"
    tags = {
        "Name" = "main"
    }
}