resource "airtelcloud_kubernetes" "this" {
  name                   = var.name
  description            = var.description
  k8s_name               = var.k8s_name
  kubernetes_version     = var.kubernetes_version
  networking_name        = var.networking_name
  networking_version     = var.networking_version
  worker_nodes           = var.worker_nodes
  availability_zone      = var.availability_zone
  os_distribution        = var.os_distribution
  control_plane_provider = var.control_plane_provider
  vpc_name               = var.vpc_name
  node_pools             = var.node_pools

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
