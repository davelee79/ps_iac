locals {
  #name = basename(path.cwd)
  name = "${var.resource_prefix}-eks-cluster"
  cluster_name = "${var.resource_prefix}-eks-cluster"
  cluster_version = "1.24"
  region       = var.aws_region

  vpc_cidr = "10.1.0.0/16"

  node_group_name   = "${var.resource_prefix}-node-group"
  worker_name = "worker_${var.resource_prefix}"

}
