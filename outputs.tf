# Region used for Terratest
output "region" {
  description = "AWS region"
  value       = local.region
}

output "vpc_id" {
  description = "The ID of the VPC"
  value = module.vpc.vpc_id
}


output "vpc_private_subnet_cidr" {
  description = "VPC private subnet CIDR"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "vpc_public_subnet_cidr" {
  description = "VPC public subnet CIDR"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks_blueprints.eks_cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS Cluster Endpoint"
  value       = module.eks_blueprints.eks_cluster_version
}

output "ec2instance" {
  value = aws_instance.ps-client.public_ip
}
