/* Install Guide
 * https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/
*/

# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/9210e6c6dc2bbd00065bc6f9212d04a0f49adec2/examples/iam-role-for-service-accounts-eks/main.tf#L184
module "albc_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller-sa"]
    }
  }
}

resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
  metadata {
    name        = "aws-load-balancer-controller-sa"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.albc_irsa_role.iam_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.4"

  values     = [
    "${file("values/albc.yaml")}"
  ]

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller_sa.metadata[0].name
  }
}