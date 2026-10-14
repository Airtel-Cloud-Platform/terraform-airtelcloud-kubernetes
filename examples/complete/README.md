# Complete Kubernetes Example

This example provisions a Kubernetes cluster using autoscaling and node metadata.

## What This Example Shows

- Autoscaling worker pool starting at zero nodes
- Labels, annotations, and taints
- Explicit control-plane provider
- Resource timeouts

## Files

- `main.tf`: complete provider and module configuration
- `variables.tf`: provider credentials

## How To Run

1. Go to this folder:

```bash
cd examples/complete
```

2. Initialize Terraform:

```bash
terraform init
```

3. Set required provider variables (API key/secret, organization, project).

4. Plan:

```bash
terraform plan
```

5. Apply:

```bash
terraform apply
```

6. Destroy when done:

```bash
terraform destroy
```

## Notes

- `count = 0` is valid because autoscaling is enabled.
- Adjust flavor, subnet, Kubernetes version, and zone to match your environment.
- Configuration changes force a new cluster.
