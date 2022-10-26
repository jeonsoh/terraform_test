output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "node_group_security_group_id" {
  description = "Node Group Security Group ID"
  value = module.eks.node_security_group_id
}

output "cluster_status" {
  description = "Kuberentes Cluster Status"
  value       = module.eks.cluster_status
}

output "cluster_oidc_issuer_url" {
  description = "Kuberentes Cluster OIDC Issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_version" {
  description = "Kuberentes Cluster Version"
  value       = module.eks.cluster_version
}
