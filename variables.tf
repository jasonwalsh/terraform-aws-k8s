variable cidr_block {
  default     = "10.0.0.0/16"
  description = "The IPv4 network range for the VPC, in CIDR notation"
  type        = string
}

variable cluster_version {
  default     = "1.15"
  description = "The desired Kubernetes version for your cluster"
  type        = string
}

variable instance_type {
  default = "m4.large"
  type    = string
}

variable max_size {
  default = 1
  type    = number
}

variable name {
  default     = ""
  description = "The unique name to give to your cluster"
  type        = string
}

variable subnet_ids {
  default     = []
  description = "Specify subnets for your Amazon EKS worker nodes"
  type        = list(string)
}

variable tags {
  default     = {}
  description = "The metadata to apply to the cluster to assist with categorization and organization"
  type        = map
}

variable users {
  default = []
  type    = list(string)
}

variable vpc_id {
  default = ""
  type    = string
}
