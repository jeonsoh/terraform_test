/*
 * https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
*/

# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/9210e6c6dc2bbd00065bc6f9212d04a0f49adec2/examples/iam-role-for-service-accounts-eks/main.tf#L84
module "ebs_csi_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "ebs-cni"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.ebs_csi_irsa_role.iam_role_arn
    }
  }
}

resource "helm_release" "aws_ebs_csi_driver" {
  name      = "aws-ebs-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.10.0"

  values = [
    "${file("values/ebs.yaml")}"
  ]

  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.ebs_csi_controller_sa.metadata[0].name
  }
}