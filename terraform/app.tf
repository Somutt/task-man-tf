# Deployment do Task-Manager
resource "kubernetes_deployment" "task_manager" {
  depends_on = [null_resource.k3d_cluster]

  metadata {
    name = "task-manager"
    labels = {
      app = "task-manager"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "task-manager"
      }
    }
    template {
      metadata {
        labels = {
          app = "task-manager"
        }
      }
      spec {
        container {
          name              = "task-manager"
          image             = "task-manager:local"
          image_pull_policy = "IfNotPresent"
          
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "task_manager_svc" {
  depends_on = [kubernetes_deployment.task_manager]

  metadata {
    name = "task-manager-service"
  }

  spec {
    type = "NodePort"
    selector = {
      app = "task-manager"
    }
    port {
      port = 80
      target_port = 3000
      node_port = 30000
    }
  }
}