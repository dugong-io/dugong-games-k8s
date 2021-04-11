resource "helm_release" "factorio" {
    depends_on = [
      helm_release.aws-load-balancer-controller
    ]
    name = "factorio"
    repository = "./charts/"
    chart = "factorio-server-charts"
    namespace = "games"
    create_namespace = true

    set {
        name = "image.tag"
        value = "1.0.0"
        type = "string"
    }

    set {
        name = "persistence.storageClass"
        value = "gp2"
        type = "string"
    }

    set {
        name = "service.type"
        value = "LoadBalancer"
        type = "string"
    }

    set {
        name = "service.port"
        value = "30000"
        type = "string"
    }

    set {
        name = "nodeSelector.subnet"
        value = "private"
        type = "string"
    }
}