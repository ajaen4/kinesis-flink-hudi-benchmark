output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "account_region" {
  value = data.aws_region.current.name
}

output "cluster_version" {
  description = "EKS version"
  value       = module.eks.cluster_version
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cloudwatch_log_group_name" {
  description = "EKS cloudwatch log name."
  value       = module.eks.cloudwatch_log_group_name
}