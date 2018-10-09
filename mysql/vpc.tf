resource "aws_vpc" "terra-aws" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "-vpc"
  }
}

# public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.terra-aws.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch=true

  tags {
     Name = "Test public subnet"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = "rds-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = ["${aws_subnet.public-subnet.id}"]
}


# private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.terra-aws.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-west-1b"

  tags {
     Name = "Test private subnet"
  }
}

# Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.terra-aws.id}"

  tags {
    Name = "vpc gateway"
  }
}

# route for internet
resource "aws_route_table" "public-route"{
  vpc_id = "${aws_vpc.terra-aws.id}"

#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = "${aws_internet_gateway.gw.id}"
#  }

  tags {
    Name = "route table"
  }
}
# Internet Access
resource "aws_route" "internet_access"{
  route_table_id = "${aws_route_table.public-route.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}
# Route with subnet
resource "aws_route_table_association" "association"{
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-route.id}"
}
# security group
resource "aws_security_group" "rds" {
  name = "rds"
  description = "inbound rules"

  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.mysql_port}"
    to_port = "${var.mysql_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.terra-aws.id}"

  tags {
    Name = "websg"
  }
}
