# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


####################  outputs for apptier  #########################################

output "launch_template_id_apptier" {
  description = "IDs of EC2 instances"
  value       = aws_launch_template.project-zeus-LTapptier.id
}
output "launch_template_version_apptier" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.project-zeus-LTapptier.latest_version
}