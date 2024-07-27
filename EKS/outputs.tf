################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.Globaltoye_eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.Globaltoye_eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.Globaltoye_eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the Globaltoye_eks cluster. Note: currently a value is returned only for local Globaltoye_eks clusters created on Outposts"
  value       = module.Globaltoye_eks.cluster_id
}

output "cluster_name" {
  description = "The name of the Globaltoye_eks cluster"
  value       = module.Globaltoye_eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the Globaltoye_eks cluster for the OpenID Connect identity provider"
  value       = module.Globaltoye_eks.cluster_oidc_issuer_url
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.Globaltoye_eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the Globaltoye_eks cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.Globaltoye_eks.cluster_status
}

output "cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon Globaltoye_eks for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the Globaltoye_eks console"
  value       = module.Globaltoye_eks.cluster_security_group_id
}

################################################################################
# Security Group
################################################################################

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.Globaltoye_eks.cluster_security_group_arn
}

################################################################################
# IRSA
################################################################################

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.Globaltoye_eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.Globaltoye_eks.oidc_provider_arn
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.Globaltoye_eks.cluster_tls_certificate_sha1_fingerprint
}

################################################################################
# IAM Role
################################################################################

output "cluster_iam_role_name" {
  description = "IAM role name of the Globaltoye_eks cluster"
  value       = module.Globaltoye_eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the Globaltoye_eks cluster"
  value       = module.Globaltoye_eks.cluster_iam_role_arn
}

output "cluster_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.Globaltoye_eks.cluster_iam_role_unique_id
}

################################################################################
# Globaltoye_eks Addons
################################################################################

output "cluster_addons" {
  description = "Map of attribute maps for all Globaltoye_eks cluster addons enabled"
  value       = module.Globaltoye_eks.cluster_addons
}

################################################################################
# Globaltoye_eks Managed Node Group
################################################################################

output "Globaltoye_eks_managed_node_groups" {
  description = "Map of attribute maps for all Globaltoye_eks managed node groups created"
  value       = module.Globaltoye_eks.eks_managed_node_groups
}

output "Globaltoye_eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by Globaltoye_eks managed node groups"
  value       = module.Globaltoye_eks.eks_managed_node_groups_autoscaling_group_names
}

################################################################################
# Additional
################################################################################

output "aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value       = module.Globaltoye_eks.aws_auth_configmap_yaml
}

