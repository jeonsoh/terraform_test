#resource "helm_release" "nginx_ingress" {
#  name      = "nginx-ingress-controller"
#  namespace = "kube-system"
#
#  repository = "https://charts.bitnami.com/bitnami"
#  chart      = "nginx-ingress-controller"
#  version    = "1.3.1"
#
#  set {
#    name  = "service.type"
#    value = "ClusterIP"
#  }
#}