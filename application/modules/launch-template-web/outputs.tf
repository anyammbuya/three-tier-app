# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

####################  outputs for webtier  #########################################

output "launch_template_id_webtier" {
  description = "IDs of EC2 instances"
  value       = aws_launch_template.project-zeus-LTwebtier.id
}
output "launch_template_version_webtier" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.project-zeus-LTwebtier.latest_version
}
