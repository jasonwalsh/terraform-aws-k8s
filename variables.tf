variable cidr_block {
  default = "10.0.0.0/16"
  type    = string
}

variable cluster_version {
  default = "1.15"
  type    = string
}

variable create_nat_gateway {
  default = true
  type    = bool
}

variable enable_dns_hostnames {
  default = true
  type    = bool
}

// WARNING: this may not be required
variable enable_dns_support {
  default = true
  type    = bool
}

variable instance_type {
  default = "m4.large"
  type    = string
}

variable map_public_ip_on_launch {
  default = true
  type    = bool
}

variable max_size {
  default = 1
  type    = number
}

variable name {
  default = ""
  type    = string
}

variable tags {
  default = {}
  type    = map
}

variable users {
  default = []
  type    = list(string)
}

variable vpc_id {
  default = ""
  type    = string
}
