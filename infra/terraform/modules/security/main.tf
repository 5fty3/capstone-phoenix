resource "aws_security_group" "k3s_cluster_sg" {
  name        = "k3s-cluster-sg"
  description = "Security group for the k3s cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "k3s-cluster-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.k3s_cluster_sg.id

  cidr_ipv4   = var.ssh_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.k3s_cluster_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.k3s_cluster_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "k3s_api" {
  security_group_id            = aws_security_group.k3s_cluster_sg.id
  referenced_security_group_id = aws_security_group.k3s_cluster_sg.id

  from_port   = 6443
  to_port     = 6443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "k3s_api_local" {
  security_group_id = aws_security_group.k3s_cluster_sg.id

  cidr_ipv4   = var.ssh_cidr
  from_port   = 6443
  to_port     = 6443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.k3s_cluster_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}