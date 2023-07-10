resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
    tags = { 
        Name = "my_vpc" 
        }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
     tags = { 
        Name = "my_igw" 
        }
}

resource "aws_eip" "my_nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_nat_eip.id
  subnet_id     = aws_subnet.my_subnets[0].id
  depends_on    = [aws_internet_gateway.my_igw]
  tags = { Name = "my_nat" }
}

resource "aws_subnet" "my_subnets" {
 count             = length(var.subnet_cidrs)
 vpc_id          =   aws_vpc.my_vpc.id
 cidr_block        = var.subnet_cidrs[count.index]
 tags              = merge(var.subnet_tags, { "Name" = "Subnet ${count.index + 1}" })

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.my_igw.id
  }
    tags = { Name = "public_route_table" }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "private_route_table" }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.my_subnets[0].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.my_subnets[1].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Public Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = var.public_sg_ingress_ports[0]
    to_port     = var.public_sg_ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.public_sg_ingress_ports[1]
    to_port     = var.public_sg_ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.public_sg_ingress_ports[2]
    to_port     = var.public_sg_ingress_ports[2]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = { Name = "public_sg" }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Private Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = var.private_sg_ingress_ports[0]
    to_port         = var.private_sg_ingress_ports[0]
    protocol        = "tcp"
    #security_groups = [aws_security_group.public_sg.id]
    cidr_blocks = [var.subnet_cidrs[0]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = { Name = "private_sg" }
}



resource "aws_instance" "public_instance" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  user_data                   = file("apache.sh")
  tags = { Name = "public_instance" }
}

resource "aws_instance" "private_instance" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnets[1].id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  user_data                   = file("apache.sh")
  tags = { Name = "private_instance" }
}