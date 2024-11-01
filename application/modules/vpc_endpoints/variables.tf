
variable "region" {
  description = "AWS region"
  }

variable "subnet_ids" {
  description = "private subnet_ids apptier"
  }

variable "vpc_endpoint_sg_id"{
    description = "security id of vpc endpoint"
}

variable "private_route_table_ids"{
    description = "ids of private route tables"
}

variable "vpc_id" {
  description = "vpc id"
  }


