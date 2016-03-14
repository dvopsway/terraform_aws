provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "customer_vpc" {
    cidr_block = "${var.vpc_cidr}"
    tags {
        Name = "vpc_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_internet_gateway" "customer_gateway" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    tags {
        Name = "igw_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_route_table" "public_rtb" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.customer_gateway.id}"
    }

    tags {
        Name = "public_rtb_${var.customer_name}"
    }
}

resource "aws_subnet" "publicsubnet1" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    availability_zone = "${lookup(var.az_1,var.region)}"
    cidr_block = "${var.publicsubnet_cidr1}"
    tags {
        Name = "publicsubnet1_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_subnet" "publicsubnet2" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    cidr_block = "${var.publicsubnet_cidr2}"
    availability_zone = "${lookup(var.az_2,var.region)}"
    tags {
        Name = "publicsubnet2_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_route_table_association" "public_rtb_association1" {
    subnet_id = "${aws_subnet.publicsubnet1.id}"
    route_table_id = "${aws_route_table.public_rtb.id}"
}

resource "aws_route_table_association" "public_rtb_association2" {
    subnet_id = "${aws_subnet.publicsubnet2.id}"
    route_table_id = "${aws_route_table.public_rtb.id}"
}

resource "aws_security_group" "nat_sg" {
  name = "allow_all"
  description = "Allow all inbound traffic"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.privatesubnet_cidr1}"]
  }
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["${var.privatesubnet_cidr1}"]
  }
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.privatesubnet_cidr2}"]
  }
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["${var.privatesubnet_cidr2}"]
  }
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat_instance" {
    ami = "${lookup(var.nat_ami, var.region)}"
    instance_type = "t2.micro"
    subnet_id = "aws_subnet.publicsubnet1.id"
    source_dest_check = false
    associate_public_ip_address = false
    tags {
        Name = "Nat_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_eip" "nat_ip" {
    instance = "${aws_instance.nat_instance.id}"
}


resource "aws_route_table" "private_rtb" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_instance.nat_instance.id}"
    }

    tags {
        Name = "private_rtb_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_subnet" "privatesubnet1" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    cidr_block = "${var.privatesubnet_cidr1}"
    availability_zone = "${lookup(var.az_1,var.region)}"
    tags {
        Name = "privatesubnet1_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_subnet" "privatesubnet2" {
    vpc_id = "${aws_vpc.customer_vpc.id}"
    cidr_block = "${var.privatesubnet_cidr2}"
    availability_zone = "${lookup(var.az_2,var.region)}"
    tags {
        Name = "privatesubnet2_${var.customer_name}"
        customer_name = "${var.customer_name}"
    }
}

resource "aws_route_table_association" "private_rtb_association1" {
    subnet_id = "${aws_subnet.privatesubnet1.id}"
    route_table_id = "${aws_route_table.private_rtb.id}"
}

resource "aws_route_table_association" "private_rtb_association2" {
    subnet_id = "${aws_subnet.privatesubnet2.id}"
    route_table_id = "${aws_route_table.private_rtb.id}"
}
