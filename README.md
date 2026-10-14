# Airtel Cloud Kubernetes Terraform Module

Terraform module for provisioning an Airtel Cloud Kubernetes (CKP) cluster using `airtelcloud_kubernetes`.

v1 supports Bring-Your-Own-Host create, read, import, and delete. Changing configuration forces a new cluster.

## Features

* Creates an Airtel Cloud Kubernetes cluster
* Configurable Kubernetes version, networking, and availability zone
* Ubuntu or Rhel node OS
* One or more BYOH worker node pools
* Optional per-pool autoscaling, labels, annotations, and taints
* Optional VPC name when a subnet name is not unique
* Kamaji or Kubeadm control plane
* Create and delete timeouts
* Supports importing an existing cluster by name

## Requirements

| Name        | Version  |
| ----------- | -------- |
| Terraform   | >= 1.5   |
| airtelcloud | >= 1.2.7 |

## Usage

### Basic Example

```hcl
module "kubernetes" {
  source = "Airtel-Cloud-Platform/kubernetes/airtelcloud"

  name               = "app-cluster"
  kubernetes_version = "v1.33.7"
  networking_name    = "calico"
  networking_version = "v3.30.6"
  availability_zone  = "S1"
  os_distribution    = "Ubuntu"
  vpc_name           = "production"

  node_pools = [
    {
      flavor      = "ccd.xLarge"
      flavor_type = "Compute dense"
      subnet_name = "private"
      count       = 1
    }
  ]
}
```

### Complete Example

```hcl
module "kubernetes" {
  source = "Airtel-Cloud-Platform/kubernetes/airtelcloud"

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
```

## Inputs

| Name                     | Description                                                                                          | Type           | Required |
| ------------------------ | ---------------------------------------------------------------------------------------------------- | -------------- | -------- |
| `name`                   | Cluster name. 1–63 characters, lowercase alphanumeric and hyphens.                                   | `string`       | Yes      |
| `kubernetes_version`     | Kubernetes version, for example `v1.33.7`.                                                           | `string`       | Yes      |
| `networking_name`        | Networking name, for example `calico`.                                                               | `string`       | Yes      |
| `networking_version`     | Networking version, for example `v3.30.6`.                                                           | `string`       | Yes      |
| `availability_zone`      | Availability zone code, for example `S1`.                                                            | `string`       | Yes      |
| `os_distribution`        | Node OS. `Ubuntu` or `Rhel`.                                                                         | `string`       | Yes      |
| `node_pools`             | BYOH worker node pools. At least one pool.                                                           | `list(object)` | Yes      |
| `description`            | Cluster description.                                                                                 | `string`       | No       |
| `k8s_name`               | Kubernetes distribution. Defaults to `CKP`.                                                          | `string`       | No       |
| `worker_nodes`           | Worker count. Omit to derive it from node pools.                                                     | `number`       | No       |
| `control_plane_provider` | `Kamaji` or `Kubeadm`. Defaults to `Kamaji`.                                                         | `string`       | No       |
| `vpc_name`               | VPC used to resolve subnet names. Required when the subnet name exists in more than one VPC.         | `string`       | No       |
| `timeouts`               | Create and delete timeouts. Provider default is 45 minutes.                                          | `object`       | No       |

### Node Pools

Each pool needs `flavor` and `subnet_name`. `count` must be at least 1 unless autoscaling is enabled. Use `count = 0` with autoscaling to start empty and grow up to `max_nodes`.

```hcl
node_pools = [
  {
    flavor            = "ccd.xLarge"
    flavor_type       = "Compute dense"
    subnet_name       = "private"
    availability_zone = "S1"
    count             = 0
    autoscaling = {
      enabled   = true
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
```

* `flavor` - Flavor name, for example `ccd.xLarge`.
* `flavor_type` - Flavor type, for example `Compute dense`.
* `subnet_name` - Subnet name. The provider resolves it to a subnet UUID.
* `availability_zone` - Pool AZ. Defaults to the cluster AZ.
* `count` - Machines in the pool. Defaults to `0`.
* `autoscaling.enabled` - Defaults to `true` when the block is present.
* `autoscaling.max_nodes` - Upper bound. Required when autoscaling is set. Must be at least 1.
* `labels` / `annotations` - Optional key/value metadata. `op` defaults to `MetaOpSet`.
* `taints.effect` - `NoSchedule`, `PreferNoSchedule`, or `NoExecute`. Defaults to `PreferNoSchedule`.

### Timeouts

```hcl
timeouts = {
  create = "45m"
  delete = "45m"
}
```

The provider default is 45 minutes.

## Outputs

| Name         | Description                                                          |
| ------------ | -------------------------------------------------------------------- |
| `id`         | Cluster name.                                                        |
| `name`       | Cluster name.                                                        |
| `state`      | Registration state. Successful provisioning is `Connected`.          |
| `created_by` | User that created the cluster, when returned by the API.            |
| `kubernetes` | Selected cluster attributes for downstream modules.                  |

## Important Notes

* Changing cluster configuration forces a new cluster.
* v1 supports the Bring-Your-Own-Host provider. The provider resource defaults that value.
* `name` must be lowercase alphanumeric and hyphens, and cannot start or end with a hyphen.
* `os_distribution` is `Ubuntu` or `Rhel` and applies to every node pool.
* A node pool `count` of `0` is valid only when `autoscaling.enabled` is true.
* Omit `worker_nodes` to let the provider use the sum of pool counts, or `1` when a pool autoscales from `0`.
* Creation waits until the cluster state is `Connected`.
* Planning `node_pools` from this module needs the provider fix on branch `fix/k8s-node-pools-unknown`. Releases through v1.2.9 reject that value during plan.

## Import

Existing clusters can be imported using the cluster name:

```shell
terraform import module.kubernetes.airtelcloud_kubernetes.this app-cluster
```

## Provider Resource

This module provisions the Airtel Cloud `airtelcloud_kubernetes` resource.
