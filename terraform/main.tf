terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}

resource "null_resource" "k3d_cluster" {
  provisioner "local-exec" {
    command = "k3d cluster create lab-cluster -p '30000:30000@loadbalancer' --wait"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete lab-cluster"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}