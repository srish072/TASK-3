provider "aws" {  
region  = "ap-south-1"  
profile = "srishti_jain"

}


resource "aws_vpc" "my-vpc" {
  cidr_block       = "192.168.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"


  tags = {
    Name = "SrishtiVPC"
}
  }



resource "aws_subnet" "public-subnet" {
  vpc_id     = "${aws_vpc.my-vpc.id}"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "Srishtisub1"
  
}
}





resource "aws_subnet" "private-subnet" {
  vpc_id     = "${aws_vpc.my-vpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"


  tags = {
    Name = "Srishtisub2"
  }
}


resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.my-vpc.id}"


  tags = {
    Name = "Srishtigw"
  }
  
}


resource "aws_route_table" "mypublicRT" {
  vpc_id = "${aws_vpc.my-vpc.id}"


 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = "${aws_internet_gateway.internet-gateway.id}"
  }
  tags = {
    Name = "SrishtiRT1"
  }
  
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.mypublicRT.id
}


resource "aws_security_group" "SrishtiSG1" {
  name        = "mywebSG"
  description = "web sg for allow tcp,ping,HTTPd,ssh"
  vpc_id      = "${aws_vpc.my-vpc.id}"
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mywebSG"
  }
}



resource "aws_security_group" "SrishtiSG2" {
  name        = "mysqlSG"
  description = "allow mysql"
  vpc_id      = "${aws_vpc.my-vpc.id}"
   
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.public-subnet.cidr_block}"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.public-subnet.cidr_block}"]
  }
  ingress {
    description = "ICMP - IPv4"
    from_port = -1
    to_port	= -1
    protocol	= "icmp"
    cidr_blocks = ["${aws_subnet.public-subnet.cidr_block}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysqlSG"
  }
 }


resource "aws_instance" "myweb" {
  ami           = "ami-004a955bfb611bf13"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.SrishtiSG1.id}"]
  key_name = "mykey123"


  tags = {
    Name = "SrishtiWebserver"
  }
  
}

resource "aws_instance" "mysql" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.SrishtiSG2.id}"]
  key_name = "mykey123"


  tags = {
    Name = "MySQL"
  }
}


