## Define Common variables #################################

variable "aws_region" {
  default     = null
  type        = string
  description = "AWS region"
}


variable "resource_prefix" {
  default     = null
  type        = string
  description = "resource prefix"
}


# tflint-ignore: terraform_unused_declarations

variable "cluster_node_instance_type" {
  description = "EC2 instance types for the cluster nodes"
  default     = "t3.2xlarge"
  type        = string
  nullable    = false
  sensitive   = false
}

variable "cluster_min_nodes" {
  description = "Minimum no. of cluster worker nodes"
  default     = 1
  type        = number
  nullable    = false
  sensitive   = false
}

variable "cluster_desired_nodes" {
  description = "Desired no. of cluster worker nodes"
  default     = 1
  type        = number
  nullable    = false
  sensitive   = false
}

variable "cluster_max_nodes" {
  description = "Maximum no. of cluster worker nodes"
  default     = 1
  type        = number
  nullable    = false
  sensitive   = false
}


variable "ps_client" {
    type = map
    default = {
     ami = "ami-03ea9ddd5edd684e5"
     itype = "t2.2xlarge"
     publicip = true
     secgroupname = "PS-Client-Sec-Group"
    }
}
