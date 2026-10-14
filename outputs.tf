output "id" {
  description = "Cluster name."
  value       = airtelcloud_kubernetes.this.id
}

output "name" {
  description = "Cluster name."
  value       = airtelcloud_kubernetes.this.name
}

output "state" {
  description = "Compass cluster registration state. Successful provisioning is Connected."
  value       = airtelcloud_kubernetes.this.state
}

output "created_by" {
  description = "User that created the cluster, when returned by the API."
  value       = airtelcloud_kubernetes.this.created_by
}

output "kubernetes" {
  description = "Selected cluster attributes for downstream modules."

  value = {
    id                     = airtelcloud_kubernetes.this.id
    name                   = airtelcloud_kubernetes.this.name
    kubernetes_version     = airtelcloud_kubernetes.this.kubernetes_version
    networking_name        = airtelcloud_kubernetes.this.networking_name
    networking_version     = airtelcloud_kubernetes.this.networking_version
    availability_zone      = airtelcloud_kubernetes.this.availability_zone
    os_distribution        = airtelcloud_kubernetes.this.os_distribution
    control_plane_provider = airtelcloud_kubernetes.this.control_plane_provider
    state                  = airtelcloud_kubernetes.this.state
    created_by             = airtelcloud_kubernetes.this.created_by
  }
}
