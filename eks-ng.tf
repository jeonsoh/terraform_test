module "eks_managed_node_group_mgmt" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = "${local.cluster_name}-mgmt"

  cluster_name = module.eks.cluster_id
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [module.vpc.private_subnets[0]]

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  cluster_security_group_id         = module.eks.node_security_group_id

  #  instance_types = ["t3.medium"]
  instance_types = ["c5.2xlarge"]

  min_size     = 1
  max_size     = 3
  desired_size = 2

  disk_size = 100

  labels = {
    "role" = "management"
  }

  tags = {
    "nodegroup-role" = "management"
  }
}

resource "null_resource" "update_node_label_mgmt" {
  depends_on = [module.eks_managed_node_group_mgmt]

  provisioner "local-exec" {
    command = <<EOT
      kubectl label node -l role="management" node-role.kubernetes.io/management="management" --overwrite
    EOT
  }
}

module "eks_managed_node_group_edge" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name = "${local.cluster_name}-edge-ng"

  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [module.vpc.private_subnets[0]]

  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  cluster_security_group_id         = module.eks.node_security_group_id

  instance_types = ["t3.medium"]

  min_size     = 1
  max_size     = 1
  desired_size = 1

  disk_size = 100

  labels = {
    "dedicated" = "edge"
  }

  tags = {
    "nodegroup-role" = "edge"
  }

  taints = [
    {
      "key"    = "dedicated"
      "value"  = "edge"
      "effect" = "NO_SCHEDULE"
    }
  ]
}

resource "null_resource" "update_node_label_edge" {
  depends_on = [module.eks_managed_node_group_edge]

  provisioner "local-exec" {
    command = <<EOT
      kubectl label node -l dedicated="edge" node-role.kubernetes.io/edge="edge" --overwrite
    EOT
  }
}
#
##module "eks_managed_node_group_logging" {
##  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
##
##  name = "${local.cluster_name}-logging-ng"
##
##  cluster_name = local.cluster_name
##  vpc_id       = module.vpc.vpc_id
##  subnet_ids   = [module.vpc.private_subnets[0]]
##
##  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
##  cluster_security_group_id         = module.eks.node_security_group_id
##
##  instance_types = ["t3.medium"]
##  instance_types = ["m5.xlarge"]
##
##  min_size     = 1
##  max_size     = 1
##  desired_size = 1
##
##  disk_size = 100
##
##  labels = {
##    "role"                            = "logging"
##    "node-role.kubernetes.io/logging" = "logging"
##  }
##
##  tags = {
##    "nodegroup-role" = "logging"
##
##  }
##
##  taints = [
##    {
##      "key"    = "logging"
##      "value"  = "true"
##      "effect" = "NO_SCHEDULE"
##    }
##  ]
##}
##
##resource "null_resource" "update_node_label_logging" {
##  depends_on = [module.eks_managed_node_group_logging]
##
##  provisioner "local-exec" {
##    command = <<EOT
##      kubectl label node -l role="logging" node-role.kubernetes.io/logging="logging" --overwrite
##    EOT
##  }
##}
##
##module "eks_managed_node_group_monitoring" {
##  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
##
##  name = "${local.cluster_name}-monitoring-ng"
##
##  cluster_name = local.cluster_name
##  vpc_id       = module.vpc.vpc_id
##  subnet_ids   = [module.vpc.private_subnets[0]]
##
##  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
##  cluster_security_group_id         = module.eks.node_security_group_id
##
##  instance_types = ["t3.medium"]
##  instance_types = ["m5.xlarge"]
##
##  min_size     = 1
##  max_size     = 1
##  desired_size = 1
##
##  disk_size = 100
##
##  labels = {
##    "role"                               = "monitoring"
##    "node-role.kubernetes.io/monitoring" = "monitoring"
##  }
##
##  tags = {
##    "nodegroup-role" = "monitoring"
##  }
##
##  taints = [
##    {
##      "key"    = "monitoring"
##      "value"  = "true"
##      "effect" = "NO_SCHEDULE"
##    }
##  ]
##}
##
##resource "null_resource" "update_node_label_monitoring" {
##  depends_on = [module.eks_managed_node_group_monitoring]
##
##  provisioner "local-exec" {
##    command = <<EOT
##      kubectl label node -l role="monitoring" node-role.kubernetes.io/monitoring="monitoring" --overwrite
##    EOT
##  }
##}