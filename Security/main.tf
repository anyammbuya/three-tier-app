provider "aws" {
  region = var.aws_region
}


data "terraform_remote_state" "z-network" {
  backend = "remote"

  config = {
    organization = "KingstonLtd"
    workspaces = {

      name         = "wsp1"
    }
  }
}

module "zeus_ec2_perms" {
  source = "./modules/ec2-permissions"
}

module "s3_file_bucket" {
  source = "./modules/s3-bucket"

  kms_key_id = module.zeus_kms.kms_key_id

  tags       = var.vpc_tags
  

}

module "zeus_kms" {
  source = "./modules/kms"

}

module "rds_aurora_mysql" {
  source = "./modules/rds-aurora"

security_group_ids = data.terraform_remote_state.z-network.outputs.dbtier_security_group_id
subnet_ids         = data.terraform_remote_state.z-network.outputs.private_subnet_ids_databasetier
  
tags       = var.vpc_tags

}