<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_version | Kubernetes version to use for EKS Cluster | `string` | `"1.23"` | no |
| namespace | Kubernetes Namespace to deploy HashiCorp Vault in | `string` | `"trident"` | no |
| vpc_cidr | VPC CIDR | `string` | `"10.0.0.0/16"` | no |

### Outputs

| Name | Description |
|------|-------------|
| kubectl_command_configure | kubectl configuration command |
<!-- END_TF_DOCS -->