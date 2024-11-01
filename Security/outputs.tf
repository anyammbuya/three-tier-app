
output "instance_profile_arn" {
  description = "arn of kms key"
  value       = module.zeus_ec2_perms.instance_profile_arn
}

output "kms_key_id" {
  description = "arn of kms key"
  value       = module.zeus_kms.kms_key_id
}

output "s3_bucket_name" {
  description = "s3 bucket name"
  value       = module.s3_file_bucket.s3_bucket_name
}