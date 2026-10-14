terraform {
  required_providers {
    airtelcloud = {
      source  = "Airtel-Cloud-Platform/airtelcloud"
      version = ">= 1.2.7"
    }
  }
}

provider "airtelcloud" {
  api_endpoint = "https://south.cloud.airtel.in"
  api_key      = var.airtel_api_key
  api_secret   = var.airtel_api_secret
  region       = "south"
  organization = var.organization
  project_name = var.project_name
}

module "kubernetes" {
  source = "../../"

  name                   = "app-cluster"
  description            = "Application Kubernetes cluster"
  kubernetes_version     = "v1.33.7"
  networking_name        = "calico"
  networking_version     = "v3.30.6"
  availability_zone      = "S1"
  os_distribution        = "Ubuntu"
  control_plane_provider = "Kamaji"
  vpc_name               = "production"

  node_pools = [
    {
      flavor      = "ccd.xLarge"
      flavor_type = "Compute dense"
      subnet_name = "private"
      count       = 0
      autoscaling = {
        max_nodes = 2
      }
      labels = [
        {
          key   = "app"
          value = "web"
        }
      ]
      annotations = [
        {
          key   = "owner"
          value = "platform"
        }
      ]
      taints = [
        {
          key    = "dedicated"
          value  = "web"
          effect = "NoSchedule"
        }
      ]
    }
  ]

  timeouts = {
    create = "45m"
    delete = "45m"
  }
}
