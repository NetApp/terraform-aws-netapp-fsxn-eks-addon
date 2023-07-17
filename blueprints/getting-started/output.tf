# Copyright (c) NetApp, Inc.
# SPDX-License-Identifier: Apache-2.0


output "kubectl_command_configure" {
  description = "kubectl configuration command"
  value       = module.eks.cluster_id
}
