# Copyright (c) NetApp, Inc.
# SPDX-License-Identifier: Apache-2.0

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

locals {
  name = "trident"
  cluster_name = "fsx-eks-${random_string.suffix.result}"

  region = "us-east-2"
  azs    = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    GithubRepo = "github.com/netapp"
  }
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.15.3"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets  
  cluster_endpoint_public_access = true

  enable_irsa = true

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {

    fsx_group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
    }
  }
}


################################################################################
# EKS Addons
################################################################################

# module "eks_blueprint_addons" {
#   # See https://github.com/aws-ia/terraform-aws-eks-blueprints/releases for latest version
#   # Example is not pinned to avoid update cycle conflicts between module and implementation
#   # tflint-ignore: terraform_module_pinned_source
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

#   eks_cluster_id       = module.eks_blueprints.eks_cluster_id
#   eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
#   eks_oidc_provider    = module.eks_blueprints.oidc_provider
#   eks_cluster_version  = module.eks_blueprints.eks_cluster_version

#   # EKS Managed Add-ons
#   enable_amazon_eks_vpc_cni    = true
#   enable_amazon_eks_coredns    = true
#   enable_amazon_eks_kube_proxy = true

#   # NetApp FSxN CSI Driver
# #   enable_fsxn_csi_driver = true
# #   fsxn_helm_config = {
# #     namespace = var.namespace
# #   }

#   tags = local.tags
# }

module "fsxn_driver" {
    source = "../../"
    helm_config = {
        namespace = var.namespace
    }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name                 = "fsx-eks-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets      = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
  tags = local.tags
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
  description       = "allow inbound traffic from eks"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.all_worker_mgmt.id
  type              = "ingress"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}