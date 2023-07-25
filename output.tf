# Copyright 2023 (c) NetApp, Inc.
# SPDX-License-Identifier: Apache-2.0

output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? { enable = true } : null
}

output "merged_helm_config" {
  description = "(merged) Helm Config for NetApp Trident"
  value       = helm_release.trident
  sensitive   = true
}