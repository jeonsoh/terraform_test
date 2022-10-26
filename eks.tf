#
# https://github.com/terraform-aws-modules/terraform-aws-eks

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  node_security_group_additional_rules = {
    albc_webhook_ingress = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  tags = local.common.tags
}

resource "null_resource" "eniconfig" {
  depends_on = [module.eks]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      az1=$(echo ${data.aws_availability_zones.available.names[0]})
      az2=$(echo ${data.aws_availability_zones.available.names[1]})
      sub1=$(echo ${module.vpc.intra_subnets[0]})
      sub2=$(echo ${module.vpc.intra_subnets[1]})
      sg=$(echo ${module.eks.node_security_group_id})
      cluster=$(echo ${local.cluster_name})

      echo $az1 $az2 $sub1 $sub2 $sg $cluster

      aws eks update-kubeconfig --name $cluster
      kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
      kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone

      ./setup_eniconfig.sh $az1 $sub1 $sg
      ./setup_eniconfig.sh $az2 $sub2 $sg
    EOT
  }
}

resource "aws_eks_addon" "coredns" {
  depends_on = [null_resource.eniconfig]

  cluster_name = module.eks.cluster_id
  addon_name   = "coredns"
  resolve_conflicts = "OVERWRITE"
}