# resource "helm_release" "valheim" {
#     depends_on = [
#       helm_release.aws-load-balancer-controller
#     ]
#     name = "valheim"
#     repository = "https://addyvan.github.io/valheim-k8s/"
#     chart = "valheim-k8s"
#     namespace = "games"
#     create_namespace = true

#     set {
#         name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
#         value = "nlb"
#         type  = "string"
#     }
# }