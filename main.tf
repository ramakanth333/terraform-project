#provider and region#
provider "aws" {
  region = "us-east-1"
}

# create vpc
#aws_vpc means resource name i.e vpc is service and myVpc is something like id
resource "aws_vpc" "myVpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myVpc"
  }
}

# create igw and attach to vpc#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVpc.id # reference

  tags = {
    Name = "igw"
  }
}

#subnet #
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myVpc.id # argument or reference
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public subnet"
  }
}

#route table#
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myVpc.id

  route = []
  tags = {
    Name = "example"
  }
}


#######  route #######

resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.rt] // depends on route table and used in production
}

###### security group #############
resource "aws_security_group" "sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myVpc.id ## vpcid reference

  ingress = [
    {
      description      = "All traffic"
      from_port        = 0    #ALl ports
      to_port          = 0    # all ports
      protocol         = "-1" # all traffic
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      description      = "outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0    #ALl ports
      to_port          = 0    # all ports
      protocol         = "-1" # all traffic
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "outbound rule"
      prefix_list_ids  = null
      security_groups  = null
      self             = null

    }
  ]

  tags = {
    Name = "all_traffic"
  }
}

# route table association #
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}

#ec2 instance"

resource "aws_instance" "ec2" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id
  tags = {
    Name = "HelloWorld"
  }
}

