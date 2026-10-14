# Basic Kubernetes Example

This example provisions a single-pool Kubernetes cluster using the module from the repository root.

## What This Example Shows

- Single cluster creation
- Fixed worker count
- Name-based VPC and subnet selection
- Minimal optional inputs

## Files

- `main.tf`: provider config + module call
- `variables.tf`: input variables used by the provider block
- `terraform.vars`: sample variable values for local testing

## How To Run

1. Go to this folder:

```bash
cd examples/basic
```

2. Initialize Terraform:

```bash
terraform init
```

3. Provide your own credentials and project details in a tfvars file (do not commit secrets).

4. Plan:

```bash
terraform plan -var-file=terraform.vars
```

5. Apply:

```bash
terraform apply -var-file=terraform.vars
```

6. Destroy when done:

```bash
terraform destroy -var-file=terraform.vars
```

## Notes

- Use your own Airtel Cloud API credentials.
- Keep credentials out of version control.
- If your environment uses a different region or API endpoint, update provider inputs accordingly.
- Adjust flavor, subnet, Kubernetes version, and zone to match your environment.
