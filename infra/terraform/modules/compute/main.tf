resource "aws_instance" "control_plane" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_1_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-control-plane"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

resource "aws_instance" "worker_1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_1_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name        = "${var.project_name}-worker-1"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

resource "aws_instance" "worker_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_2_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  tags = {
    Name        = "${var.project_name}-worker-2"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}

resource "aws_eip" "control_plane_eip" {
  instance = aws_instance.control_plane.id
  domain   = "vpc"

  tags = {
    Name = "phoenix-control-plane-eip"
  }
}