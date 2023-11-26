resource "aws_vpc" "VPC-akhil" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "VPC"
  }
}
##############################################################################
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.VPC-akhil.id
  count = length(var.public_Subnet)
  cidr_block = var.public_Subnet[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "public-subnet${count.index +1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC-akhil.id

  tags = {
    Name = "aws_internet_gateway"
  }
}

resource "aws_route_table" "public-route-table" {
  count = 3
  vpc_id = aws_vpc.VPC-akhil.id

  route {
    cidr_block = var.routtable_cidr
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public${count.index + 1}"
  }
}
resource "aws_route_table_association" "ARI" {
  count          = length(var.public_Subnet)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-route-table[count.index % 3].id
}
##################################################################################################
resource "aws_eip" "EIP" {
 
}
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }
}


resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.VPC-akhil.id
  count = length(var.private_Subnet)
  cidr_block = var.private_Subnet[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "private-subnet${count.index +1}"
  }
}


resource "aws_route_table" "private-route-table" {
  count = 3
  vpc_id = aws_vpc.VPC-akhil.id

  route {
    cidr_block = var.routtable_cidr
    gateway_id = aws_nat_gateway.NAT.id
  }
  tags = {
    Name = "private${count.index +1}"
  }
}

resource "aws_route_table_association" "ARN" {
  count          = length(var.private_Subnet)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-route-table[count.index % 3].id
}

##############################################################################
resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.VPC-akhil.id
    dynamic "ingress" {
    for_each = var.rules
      content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
##############################################################################
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kyc_app_public_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kyc_app_public_key.key_name}.pem"
  content = tls_private_key.rsa-4096.private_key_pem
}

