# Amazon FSx for NetApp ONTAP CSI driver EKS Add-on

> Deploy NetApp Astra Trident to AWS EKS Clusters with this add-on.

## Table of Contents

- [NetApp Astra Trident Addon for AWS EKS](#netapp-trident-addon-for-aws-eks)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Author Information](#author-information)
  - [License](#license)

## Usage

If you would like to override any defaults with the chart, you can do so by passing the `helm_config` variable.

For a more extensive example, see [blueprints/getting-started](./blueprints/getting-started/).


Refer to [this guide](https://docs.netapp.com/us-en/trident/trident-use/trident-fsx.html#drivers) for a detailed overview on how to get started.

<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| helm_config | NetApp Trident Helm chart configuration | `any` | `{}` | no |
| manage_via_gitops | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| argocd_gitops_config | Configuration used for managing the add-on with ArgoCD |
| merged_helm_config | (merged) Helm Config for NetApp Trident |
<!-- END_TF_DOCS -->

## Author Information

This repository is maintained by the contributors listed on [GitHub](https://github.com/NetApp/terraform-aws-netapp-fsxn-eks-addon/graphs/contributors).

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
