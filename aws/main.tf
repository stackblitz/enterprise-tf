data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

resource "aws_security_group" "main" {
  name = "${var.prefix}-stackblitz"

  description = "Security group for authorizing incoming Stackblitz traffic"
  vpc_id      = data.aws_subnet.selected.vpc_id

  // allow http (over public IP if available)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.create_public_ip ? ["0.0.0.0/0"] : [data.aws_vpc.selected.cidr_block]
  }

  // allow https traffic
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.create_public_ip ? ["0.0.0.0/0"] : [data.aws_vpc.selected.cidr_block]
  }

  // To Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.create_public_ip && !var.vpn_available ? ["0.0.0.0/0"] : [data.aws_vpc.selected.cidr_block]
  }

  // Allow Kubernetes
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.create_public_ip && !var.vpn_available ? ["0.0.0.0/0"] : [data.aws_vpc.selected.cidr_block]
  }

  // Allow kotsadm
  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = var.create_public_ip && !var.vpn_available ? ["0.0.0.0/0"] : [data.aws_vpc.selected.cidr_block]
  }

  // Allow grafana
  ingress {
    from_port   = 30902
    to_port     = 30902
    protocol    = "tcp"
    cidr_blocks = var.create_public_ip && !var.vpn_available ? ["0.0.0.0/0"] : [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "StackBlitz Allow ingress"
  }

  // Allow grafana
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "main" {
  count = var.create_public_ip ? 1 : 0
  vpc   = true
}

resource "aws_eip_association" "main" {
  count         = var.create_public_ip ? 1 : 0
  allocation_id = aws_eip.main[0].id
  instance_id   = aws_instance.main.id
  # network_interface_id = aws_network_interface.main.id
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.main.id]

  root_block_device {
    volume_size = 200
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.prefix}-stackblitz"
  }
}
