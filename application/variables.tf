variable "instance_type" {
  description = "ec2-instance type"
  type        = string
  default     = "t2.micro"
}


variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    project     = "zeus"
    Environment = "dev"
  }
}