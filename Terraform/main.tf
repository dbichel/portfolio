provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "local_file" "ansible_inventory"{
  filename = "../Ansible/ansible_inventory"
  content = templatefile(
    "ansible_inventory.tftpl",
    {
      jumphost_ip = aws_instance.jumphost.public_ip,
      control_node_ips = [aws_instance.controller.private_ip]
      worker_node_ips = aws_instance.worker[*].private_ip
    }
  )
  lifecycle {
    replace_triggered_by = [
      aws_instance.jumphost.public_ip
    ]
  }
}