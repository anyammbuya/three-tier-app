# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


#################|  Launch Template Resource for webtier   |##########################

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = "${file("${path.module}/mykey.pub")}"
}

resource "aws_launch_template" "project-zeus-LTwebtier" {
  
  name          = "project-zeus-LTwebtier"
  description   = "Launch Template for webtier"
  image_id      = "ami-0caa8202f35a25ceb"
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids_webtier
  
  key_name = aws_key_pair.mykeypair.key_name

/*
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids_webtier
  }
 */
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
