
########################    Outputs for webtier    ####################################

output "autoscaling_group_id_wt" {
  description = "Autoscaling Group ID"
  value = aws_autoscaling_group.webtier_zeus_ASG.id 
}

output "autoscaling_group_name_wt" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.webtier_zeus_ASG.name 
}

output "autoscaling_group_arn_wt" {
  description = "Autoscaling Group ARN"
  value = aws_autoscaling_group.webtier_zeus_ASG.arn 
}
