provider "aws" {
  region = data.terraform_remote_state.z-network.outputs.aws_region
}

data "terraform_remote_state" "z-network" {
  backend = "remote"

  config = {
    organization = "KingstonLtd"
    workspaces = {

      name = "wsp1"
    }
  }
}

data "terraform_remote_state" "z-security" {
  backend = "remote"

  config = {
    organization = "KingstonLtd"
    workspaces = {

      name = "wsp2"
    }
  }
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}



#######################           webtier       ########################################

module "exalb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "exlb-${random_string.lb_id.result}-project-zeus"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.z-network.outputs.vpc_id
  subnets         = data.terraform_remote_state.z-network.outputs.public_subnet_ids_webtier
  security_groups = [data.terraform_remote_state.z-network.outputs.exlb_security_group_id]

  target_groups = [
    {
      name_prefix      = "webt-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.vpc_tags


}

module "webtier_launch_template" {
  source = "./modules/launch-template-web"

  instance_type              = var.instance_type
  tags                       = var.vpc_tags
  
  #security_group_ids_webtier = [data.terraform_remote_state.z-network.outputs.webtier_security_group_id]
  
}

module "webtier_autoscaling_group" {
  source = "./modules/autoscaling-group-web"

  subnet_ids_wt              = data.terraform_remote_state.z-network.outputs.public_subnet_ids_webtier
  target_group_arns_wt       = module.exalb.target_group_arns
  launch_template_id_wt      = module.webtier_launch_template.launch_template_id_webtier
  launch_template_version_wt = module.webtier_launch_template.launch_template_version_webtier
}



#######################           apptier       ########################################

module "inalb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "inlb-${random_string.lb_id.result}-project-zeus"

  load_balancer_type = "application"
  internal           = true

  vpc_id          = data.terraform_remote_state.z-network.outputs.vpc_id
  subnets         = data.terraform_remote_state.z-network.outputs.private_subnet_ids_apptier
  security_groups = [data.terraform_remote_state.z-network.outputs.inlb_security_group_id]

  target_groups = [
    {
      name_prefix      = "appt-"
      backend_protocol = "HTTP"
      backend_port     = 4000
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = var.vpc_tags
}

module "apptier_launch_template" {
  source = "./modules/launch-template-app"

  instance_type              = var.instance_type
  security_group_ids_apptier = [data.terraform_remote_state.z-network.outputs.apptier_security_group_id]
  instance_profile_arn       = data.terraform_remote_state.z-security.outputs.instance_profile_arn
  tags                       = var.vpc_tags
}

module "apptier_autoscaling_group" {
  source = "./modules/autoscaling-group-app"

  subnet_ids_appt              = data.terraform_remote_state.z-network.outputs.private_subnet_ids_apptier
  target_group_arns_appt       = module.inalb.target_group_arns
  launch_template_id_appt      = module.apptier_launch_template.launch_template_id_apptier
  launch_template_version_appt = module.apptier_launch_template.launch_template_version_apptier
}

module "session-manager-settings" {
  source = "gazoakley/session-manager-settings/aws"

  kms_key_id                    = data.terraform_remote_state.z-security.outputs.kms_key_id
  s3_encryption_enabled         = true
  s3_bucket_name                = data.terraform_remote_state.z-security.outputs.s3_bucket_name
}
# The cli command below will rectify issues when error arise with this session-manager-settings module
# aws ssm delete-document --name SSM-SessionManagerRunShell --region us-east-2


module "vpc_endpoints"{
  source = "./modules/vpc_endpoints"

region            = data.terraform_remote_state.z-network.outputs.aws_region
vpc_id            = data.terraform_remote_state.z-network.outputs.vpc_id
subnet_ids        = data.terraform_remote_state.z-network.outputs.private_subnet_ids_apptier
private_route_table_ids = data.terraform_remote_state.z-network.outputs.private_route_table_ids_apptier
vpc_endpoint_sg_id= data.terraform_remote_state.z-network.outputs.vpce_security_group_id

}


/*
module "zeus_cloudwatch" {
  source = "./modules/cloudwatch"

  kms_key_id = data.terraform_remote_state.z-security.outputs.kms_key_id
}

*/