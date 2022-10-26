# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/9210e6c6dc2bbd00065bc6f9212d04a0f49adec2/examples/iam-role-for-service-accounts-eks/main.tf#L100
module "efs_csi_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "efs-cni"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "kubernetes_service_account" "efs_csi_controller_sa" {
  metadata {
    name = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.efs_csi_irsa_role.iam_role_arn
    }
  }
}

resource "helm_release" "aws_efs_csi_driver" {
  name      = "aws-efs-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = "2.2.7"

  values = [
    "${file("values/efs.yaml")}"
  ]

  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.efs_csi_controller_sa.metadata[0].name
  }

  set {
    name  = "storageClasses[0].parameters.fileSystemId"
    value = aws_efs_access_point.zcp_control_plane_csi.file_system_id
  }

  set {
    name  = "storageClasses[1].parameters.fileSystemId"
    value = aws_efs_access_point.zcp_control_plane_csi.file_system_id
  }
}

