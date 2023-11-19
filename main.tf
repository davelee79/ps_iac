provider "aws" {
  region = local.region
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}


provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
#---------------------------------------------------------------
# EKS 
#---------------------------------------------------------------
module "eks_blueprints" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints"
  source = "github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=v4.32.1"

  cluster_name = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  cluster_enabled_log_types = []

  managed_node_groups = {
    worker_nodes = {
      node_group_name = "${local.node_group_name}"
      instance_types  = [ var.cluster_node_instance_type ]
      min_size        = var.cluster_min_nodes
      desired_size    = var.cluster_desired_nodes
      max_size        = var.cluster_max_nodes
      subnet_ids      = module.vpc.private_subnets
    }
  }

}

module "eks_blueprints_kubernetes_addons" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons"
  source = "github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=v4.32.1/modules/kubernetes-addons"
  
  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Self-managed Add-ons
  enable_aws_load_balancer_controller = false
  enable_metrics_server               = false
  enable_cluster_autoscaler           = false
  enable_aws_cloudwatch_metrics       = false

  enable_ingress_nginx                = false
  enable_argocd                       = false

}
#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "3.18.1"  # latest version

  name = "${local.name}-vpc"
  cidr = local.vpc_cidr

  azs             = ["${local.region}a", "${local.region}b"]    # local.azs
  public_subnets  = ["10.1.2.0/24", "10.1.3.0/24"]   # [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = ["10.1.12.0/24", "10.1.13.0/24"]    # [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = false
  one_nat_gateway_per_az  = true
  
  enable_dns_hostnames = true
  enable_dns_support = true
  create_igw = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

}

resource "aws_security_group" "ps-client-sg" {
  name = lookup(var.ps_client, "secgroupname")
  description = lookup(var.ps_client, "secgroupname")
  vpc_id = module.vpc.vpc_id

  // To Allow mstsc Transport
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "ps-client" {
  ami = lookup(var.ps_client, "ami")
  instance_type = lookup(var.ps_client, "itype")
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = lookup(var.ps_client, "publicip")


  vpc_security_group_ids = [
    aws_security_group.ps-client-sg.id
  ]

  tags = {
    Name ="t3_ps_client"
  }

  depends_on = [ aws_security_group.ps-client-sg ]
}
