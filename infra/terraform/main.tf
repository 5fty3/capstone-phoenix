module "network" {
  source = "./modules/network"

  aws_region            = var.aws_region
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}


module "security" {
  source = "./modules/security"

  vpc_id   = module.network.vpc_id
  ssh_cidr = var.ssh_cidr
}

module "compute" {
  source = "./modules/compute"

  project_name       = var.project_name
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_name           = var.key_name
  public_subnet_1_id = module.network.public_subnet_1_id
  public_subnet_2_id = module.network.public_subnet_2_id
  security_group_id  = module.security.security_group_id
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"

  content = templatefile(
    "${path.module}/templates/inventory.tftpl",
    {
      control_plane_public_ip  = module.compute.control_plane_public_ip
      control_plane_private_ip = module.compute.control_plane_private_ip

      worker_public_ips  = module.compute.worker_public_ips
      worker_private_ips = module.compute.worker_private_ips
    }
  )
}