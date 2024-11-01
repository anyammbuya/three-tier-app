# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#################|  Launch Template Resource for apptier   |##########################

resource "aws_launch_template" "project-zeus-LTapptier" {
  
  name          = "project-zeus-LTapptier"
  description   = "Launch Template for apptier"
  image_id      = "ami-01a9042662e88888d"
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids_apptier
  

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  //ebs_optimized = true
  
  #default_version = 1

  update_default_version = false
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10     
      delete_on_termination = true
      volume_type = "gp3" # default is gp3
     }
  }
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags =var.tags
  }
}

