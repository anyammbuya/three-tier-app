variable "tags" {
  description = "vpc tags"
}

variable "project_name" {
  description = "project name"
  default     = "zeus"
}

variable "security_group_ids"{
  description = "vpc_security_group_ids for database tier"  
}

variable "subnet_ids"{
  description = "subnet_ids for database tier"  
}

