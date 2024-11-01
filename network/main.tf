# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}

data "http" "myip" {
  url = "https://ifconfig.me/ip"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  cidr = var.vpc_cidr_block
  name = var.vpc_name

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, 4)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, 2)

  # This ensures that the dafault NACL for the VPC has rules only for ipv4

  default_network_acl_ingress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]

  default_network_acl_egress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  enable_ipv6 = false

  tags = var.vpc_tags

}

# External Load balancer security group
module "exlb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "IFlb-sg-project-zeus"           //IF=Internet Facing
  description = "External Load balancer security group"

  ingress_with_cidr_blocks = [

    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "http from every where"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "https from every where"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.vpc_tags
}

# Web server security group

module "webtier_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "webtier-sg-project-zeus"
  description = "Web server security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.exlb_security_group.security_group_id
      description              = "Allows http from IFlb-sg-project-zeus"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks =  "${chomp(data.http.myip.response_body)}/32"
      description = "Allows ssh from my ip"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 80 at any destination"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 443 at any destination"
    }
  ]

  tags = var.vpc_tags
}

#Security group of Internal load Balancer

module "inlb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "INlb-sg-project-zeus"        //IN=Internal 
  description = "Security group of Internal load Balancer"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.webtier_security_group.security_group_id
      description              = "Allows http from webtier_security_group"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  computed_egress_with_source_security_group_id = [
    {
      from_port                = 4000
      to_port                  = 4000
      protocol                 = "tcp"
      description              = "initiate traffic outbound to apptier on port 4000"
      source_security_group_id = module.apptier_security_group.security_group_id
    }
  ]
  number_of_computed_egress_with_source_security_group_id = 1

  tags = var.vpc_tags
}

# security group for App-tier

 module "apptier_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  name        = "apptier-sg-project-zeus"
  description = "security group for App-tier"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 4000
      to_port                  = 4000
      protocol                 = "tcp"
      description              = "Allow traffic from INlb-sg-project-zeus on port 4000"
      source_security_group_id = module.inlb_security_group.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

   ingress_with_cidr_blocks = [
    {
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      description = "Allow traffic from my IP on port 4000"
      cidr_blocks = "${chomp(data.http.myip.response_body)}/32"
    },
  ]

  egress_with_cidr_blocks = [
    
    {
      rule        = "https-443-tcp"   //necessary to intiate ssm and internet download
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 443 at any destination"
    },
    {
      rule        = "http-80-tcp"    //necessary to initiate a download from a site running on port 80
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 80 at any destination"
    }
  ]

  computed_egress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.dbtier_security_group.security_group_id
      description              = "initiate a connection to the database"
    }
  ]
  number_of_computed_egress_with_source_security_group_id = 1

}
 
# security group for database-tier

module "dbtier_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "dbtier-sg-project-zeus"        
  description = "security group for database-tier"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.apptier_security_group.security_group_id
      description              = "Allows traffic from apptier_security_group"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = var.vpc_tags
}

# VPC endpoint security group

module "vpce_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = module.vpc.vpc_id

  use_name_prefix = false

  name        = "vpce-sg-project-zeus"           
  description = "security group for vpc endpoint"

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.vpc_cidr_block
    }
  ]

  egress_with_cidr_blocks = [

    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "https to every where"
    }
  ]

  tags = var.vpc_tags
}


