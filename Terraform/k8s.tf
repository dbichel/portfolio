resource "aws_subnet" "k8s" {
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 1, 1)
    availability_zone = var.availability_zone

    tags = {
        Name = "${var.name_prefix}-k8s-subnet"
    }
}

resource "aws_security_group" "k8s" {
    name = "${var.name_prefix}-k8s-sg"
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.name_prefix}-k8s-sg"
    }
}

resource "aws_instance" "controller" {
    ami = var.ami
    instance_type = "t3.micro"
    
    subnet_id = aws_subnet.k8s.id
    vpc_security_group_ids = [
        aws_security_group.k8s.id
    ]

    tags = {
        Name = "${var.name_prefix}-k8s-controller"
    }
}

resource "aws_instance" "worker" {
    count = var.workers
    ami = var.ami
    instance_type = "t3.micro"
    
    subnet_id = aws_subnet.k8s.id
    vpc_security_group_ids = [
        aws_security_group.k8s.id
    ]

    tags = {
        Name = "${var.name_prefix}-k8s-worker-${count.index}"
    }
}