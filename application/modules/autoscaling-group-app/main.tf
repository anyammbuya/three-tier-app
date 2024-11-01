
###############################   ASG for apptier   ##################################

resource "aws_autoscaling_group" "apptier_zeus_ASG" {

  name_prefix = "appt-"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  vpc_zone_identifier  = var.subnet_ids_appt
  
  target_group_arns = var.target_group_arns_appt
  health_check_type = "EC2"
  health_check_grace_period = 300 

 # use a lifecycle argument to ignore changes to the desired capacity and target groups
 # when terraform changes other aspects of your configuration

  lifecycle { 
    ignore_changes = [desired_capacity, target_group_arns]
  }

  
  # Launch Template
  launch_template {
    id      = var.launch_template_id_appt
    version = var.launch_template_version_appt
  }
  
  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      instance_warmup = 300 
      min_healthy_percentage = 50
    }
    
  }  
   tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }  
  tag {
    key                 = "project"
    value               = "zeus"
    propagate_at_launch = true
  }  
}

resource "aws_autoscaling_policy" "avg_cpu_utilization_appt" {

  name                   = "avg_cpu_utilization_appt"

  policy_type = "TargetTrackingScaling"  

  autoscaling_group_name = aws_autoscaling_group.apptier_zeus_ASG.name

  estimated_instance_warmup = 300  # 300 secs is default anyway

  # CPU Utilization is above 50

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }  

}