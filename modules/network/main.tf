resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "production-platform-vpc"
  }

}

resource "aws_subnet" "public" {


  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_cidr[count.index]

  availability_zone = var.availability_zone[count.index]


 map_public_ip_on_launch = false
  tags = {
    "Name" = "production-platform-public-1${count.index + 1}"
  }

}

resource "aws_subnet" "private" {


  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_cidr[count.index]

  availability_zone = var.availability_zone[count.index]


 map_public_ip_on_launch = false
  tags = {
    "Name" = "production-platform-private-1${count.index + 1}"
  }

}
