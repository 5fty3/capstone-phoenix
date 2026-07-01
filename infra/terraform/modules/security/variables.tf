variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR block allowed to SSH into the instances"
  type        = string
}