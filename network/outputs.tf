output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "exlb_security_group_id" {
  description = "sg id of internet facing load balancer"
  value       = module.exlb_security_group.security_group_id
}

output "webtier_security_group_id" {
  description = "sg id for webtier"
  value       = module.webtier_security_group.security_group_id
}

output "inlb_security_group_id" {
  description = "sg id for internal load balancer"
  value       = module.inlb_security_group.security_group_id
}

output "apptier_security_group_id" {
  description = "sg id for apptier"
  value       = module.apptier_security_group.security_group_id
}

output "dbtier_security_group_id" {
  description = "sg id for dbtier"
  value       = module.dbtier_security_group.security_group_id
}

output "public_subnet_ids_webtier" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids_apptier" {
  description = "Private subnet IDs"
  value       = slice(module.vpc.private_subnets, 0, 2)
}

output "private_subnet_ids_databasetier" {
  description = "Private subnet IDs"
  value       = slice(module.vpc.private_subnets, 2, 4)
}

# we have just one route table for all private subnets

output "private_route_table_ids_apptier" {
  description = "Route table id of private subnets"
  value       = module.vpc.private_route_table_ids
}

output "vpce_security_group_id" {
  description = "sg id for vpc endpoint"
  value       = module.vpce_security_group.security_group_id
}

/*
output "database_subnet_group_name" {
  description = "database subnet group name"
  value       = module.vpc.database_subnet_group_name
}
*/
