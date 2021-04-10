# # Deploy a test nginx machine
# resource "helm_release" "nginx" {
# 	depends_on = [
# 	  helm_release.aws-load-balancer-controller
# 	]
# 	name = "nginx"
# 	repository = "https://charts.bitnami.com/bitnami"
# 	chart = "nginx"
# 	namespace = "web"
# 	create_namespace = true

#     set {
#         name  = "controller.service.annotations.service.beta.kubernetes.io/aws-load-balancer-type"
#         value = "nlb"
#         type  = "string"
#     }
# }