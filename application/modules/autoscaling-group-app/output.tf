
########################    Outputs for apptier    ####################################

output "autoscaling_group_id_appt" {
  description = "Autoscaling Group ID"
  value = aws_autoscaling_group.apptier_zeus_ASG.id 
}

output "autoscaling_group_name_appt" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.apptier_zeus_ASG.name 
}

output "autoscaling_group_arn_appt" {
  description = "Autoscaling Group ARN"
  value = aws_autoscaling_group.apptier_zeus_ASG.arn 
}
