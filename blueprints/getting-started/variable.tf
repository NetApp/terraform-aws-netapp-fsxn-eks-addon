# Copyright 2023 (c) NetApp, Inc.
# SPDX-License-Identifier: Apache-2.0

variable "cluster_version" {
  type        = string
  description = "Kubernetes version to use for EKS Cluster"
  default     = "1.23"
}

variable "namespace" {
  type        = string
  description = "Kubernetes Namespace to deploy HashiCorp Vault in"
  default     = "trident"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
