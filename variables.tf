#########################################
# Identity
#########################################

variable "name" {
  description = "Cluster name. Lowercase letters, digits, and hyphens. Forces a new cluster."
  type        = string

  validation {
    condition = (
      length(var.name) >= 1 &&
      length(var.name) <= 63 &&
      can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name))
    )
    error_message = "name must be 1-63 characters, lowercase alphanumeric and hyphens, and cannot start or end with a hyphen."
  }
}

variable "description" {
  description = "Cluster description. Forces a new cluster."
  type        = string
  default     = null
}

variable "k8s_name" {
  description = "Kubernetes distribution. Defaults to CKP. Forces a new cluster."
  type        = string
  default     = "CKP"

  validation {
    condition     = length(trim(var.k8s_name, " ")) > 0
    error_message = "k8s_name cannot be empty."
  }
}

#########################################
# Cluster
#########################################

variable "kubernetes_version" {
  description = "Kubernetes version shown in Cloud Compass (for example v1.33.7). Forces a new cluster."
  type        = string

  validation {
    condition     = length(trim(var.kubernetes_version, " ")) > 0
    error_message = "kubernetes_version cannot be empty."
  }
}

variable "networking_name" {
  description = "Networking name shown in Cloud Compass (for example calico). Forces a new cluster."
  type        = string

  validation {
    condition     = length(trim(var.networking_name, " ")) > 0
    error_message = "networking_name cannot be empty."
  }
}

variable "networking_version" {
  description = "Networking version shown in Cloud Compass (for example v3.30.6). Forces a new cluster."
  type        = string

  validation {
    condition     = length(trim(var.networking_version, " ")) > 0
    error_message = "networking_version cannot be empty."
  }
}

variable "worker_nodes" {
  description = "Worker count. Omit to use the sum of node pool counts, or 1 when a pool autoscales from 0. Forces a new cluster."
  type        = number
  default     = null
}

variable "availability_zone" {
  description = "Availability zone code (for example S1). Forces a new cluster."
  type        = string

  validation {
    condition     = length(trim(var.availability_zone, " ")) > 0
    error_message = "availability_zone cannot be empty."
  }
}

variable "os_distribution" {
  description = "Node OS distribution applied to every pool. Ubuntu or Rhel. Forces a new cluster."
  type        = string

  validation {
    condition     = contains(["Ubuntu", "Rhel"], var.os_distribution)
    error_message = "os_distribution must be Ubuntu or Rhel."
  }
}

variable "control_plane_provider" {
  description = "Control-plane provider. Kamaji or Kubeadm. Defaults to Kamaji. Forces a new cluster."
  type        = string
  default     = "Kamaji"

  validation {
    condition     = contains(["Kamaji", "Kubeadm"], var.control_plane_provider)
    error_message = "control_plane_provider must be Kamaji or Kubeadm."
  }
}

variable "vpc_name" {
  description = "VPC name used to resolve node pool subnet names. Required when the same subnet name exists in more than one VPC. Forces a new cluster."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_name == null || length(trim(var.vpc_name, " ")) > 0
    error_message = "vpc_name cannot be an empty string."
  }
}

#########################################
# Node pools
#########################################

variable "node_pools" {
  description = "BYOH worker node pools. At least one pool is required. Forces a new cluster."

  type = list(object({
    flavor            = string
    flavor_type       = optional(string)
    subnet_name       = string
    availability_zone = optional(string)
    count             = optional(number, 0)
    autoscaling = optional(object({
      enabled   = optional(bool, true)
      max_nodes = number
    }))
    labels = optional(list(object({
      key   = string
      value = optional(string)
      op    = optional(string, "MetaOpSet")
    })))
    annotations = optional(list(object({
      key   = string
      value = optional(string)
      op    = optional(string, "MetaOpSet")
    })))
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = optional(string, "PreferNoSchedule")
      op     = optional(string, "MetaOpSet")
    })))
  }))

  validation {
    condition     = length(var.node_pools) >= 1
    error_message = "node_pools must contain at least one pool."
  }

  validation {
    condition = alltrue([
      for pool in var.node_pools :
      length(trim(pool.flavor, " ")) > 0 && length(trim(pool.subnet_name, " ")) > 0
    ])
    error_message = "each node pool needs a non-empty flavor and subnet_name."
  }

  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.count >= 0 && (pool.count >= 1 || (pool.autoscaling != null && pool.autoscaling.enabled))
    ])
    error_message = "node pool count must be at least 1 unless autoscaling.enabled is true."
  }

  validation {
    condition = alltrue([
      for pool in var.node_pools :
      pool.autoscaling == null || pool.autoscaling.max_nodes >= 1
    ])
    error_message = "autoscaling.max_nodes must be at least 1."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.node_pools : [
        for taint in coalesce(pool.taints, []) :
        contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
      ]
    ]))
    error_message = "taint effect must be NoSchedule, PreferNoSchedule, or NoExecute."
  }
}

#########################################
# Timeouts
#########################################

variable "timeouts" {
  description = "Create and delete timeouts. Provider default is 45 minutes."

  type = object({
    create = optional(string)
    delete = optional(string)
  })

  default = null
}
