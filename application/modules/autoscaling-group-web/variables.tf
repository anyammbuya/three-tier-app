#######################   webtier variables   ########################################

variable "subnet_ids_wt" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}
variable "target_group_arns_wt" {
  description = "ARN of the target group"
  type        = list(string)
}
variable "launch_template_id_wt" {
  description = "ID of launch template"
  type        = string
}
variable "launch_template_version_wt" {
  description = "version of launch template"
  type        = string
}
