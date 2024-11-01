################# Outputs for webtier ###########################

output "external_alb_dns_name" {
  description = "ID of app_security_group"
  value       = module.exalb.lb_dns_name
}
output "target_group_arns_wt" {
  description = "ID of app_security_group"
  value       = module.exalb.target_group_arns
}

output "launch_template_version_wt" {
  description = "Latest version of the launch template"
  value       = module.webtier_launch_template.launch_template_version_webtier
}

output "launch_template_id_wt" {
  description = "Latest version of the launch template"
  value       = module.webtier_launch_template.launch_template_id_webtier
}

output "autoscaling_group_id_wt" {
  description = "Autoscaling Group ID"
  value       = module.webtier_autoscaling_group.autoscaling_group_id_wt
}

################# Outputs for apptier ###########################

output "internal_alb_dns_name" {
  description = "ID of app_security_group"
  value       = module.inalb.lb_dns_name
}
output "target_group_arns_appt" {
  description = "ID of app_security_group"
  value       = module.inalb.target_group_arns
}

output "launch_template_version_appt" {
  description = "Latest version of the launch template"
  value       = module.apptier_launch_template.launch_template_version_apptier
}

output "launch_template_id_appt" {
  description = "Latest version of the launch template"
  value       = module.apptier_launch_template.launch_template_id_apptier
}

output "autoscaling_group_id_appt" {
  description = "Autoscaling Group ID"
  value       = module.apptier_autoscaling_group.autoscaling_group_id_appt
}