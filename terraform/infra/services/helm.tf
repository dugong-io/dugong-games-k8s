# Get the eks cluster information
data "aws_eks_cluster" "dugong-cluster-data" {
	name = "dugong-cluster"
}

data "aws_eks_cluster_auth" "dugong-cluster-auth" {
	name = "dugong-cluster"
}

# Deploy the kube-prometheus-stack service
resource "helm_release" "kube-prometheus-stack" {
	name             = "kube-prometheus-stack"
	repository       = "https://prometheus-community.github.io/helm-charts" 
	chart            = "kube-prometheus-stack"
	namespace        = "monitoring"
	create_namespace = true

	set {
		name  = "apiService.create"
		value = "true"
	}
}

# Deploy a minecraft server
resource "helm_release" "minecraft" {
	name = "minecraft"
	repository = "https://itzg.github.io/minecraft-server-charts"
	chart = "minecraft"
	namespace = "game"
	create_namespace = true

	set {
		name = "minecraftServer.eula"
		value = true
		type = "auto"
	}
}