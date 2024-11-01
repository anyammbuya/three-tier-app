
########################   apptier variables  #######################################

variable "subnet_ids_appt" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}
variable "target_group_arns_appt" {
  description = "ARN of the target group"
  type        = list(string)
}
variable "launch_template_id_appt" {
  description = "ID of launch template"
  type        = string
}
variable "launch_template_version_appt" {
  description = "version of launch template"
  type        = string
}
