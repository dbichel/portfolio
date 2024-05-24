resource "aws_route_table" "jumphost" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "jumphost" {
  route_table_id         = aws_route_table.jumphost.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "jumphost" {
  subnet_id      = aws_subnet.jumphost.id
  route_table_id = aws_route_table.jumphost.id
}

resource "aws_subnet" "jumphost" {
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 1, 0)
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.name_prefix}-subnet"
  }
}

resource "aws_security_group" "jumphost" {
  name   = "${var.name_prefix}-jumphost-sg"
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name_prefix}-jumphost-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jumphost_ssh" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "jumphost_allow_all" {
  security_group_id = aws_security_group.jumphost.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "tls_private_key" "jumphost" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "jumphost" {
  key_name   = "${var.name_prefix}-keypair"
  public_key = tls_private_key.jumphost.public_key_openssh
}

resource "local_sensitive_file" "jumphost_key" {
  content         = tls_private_key.jumphost.private_key_openssh
  filename        = "../${var.name_prefix}_rsa"
  file_permission = "0600"
}

resource "aws_instance" "jumphost" {
  ami           = var.ami
  instance_type = "t3.micro"
  key_name      = aws_key_pair.jumphost.key_name
  availability_zone = "us-east-1a"

  subnet_id = aws_subnet.jumphost.id
  vpc_security_group_ids = [
    aws_security_group.jumphost.id
  ]
  associate_public_ip_address = true

  tags = {
    Name = "${var.name_prefix}-jumphost"
  }
}