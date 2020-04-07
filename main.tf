locals {
  map_users = [
    for i, user in var.users :
    {
      groups   = ["system:masters"]
      userarn  = element(data.aws_iam_user.iam_user.*.arn)
      username = user
    }
  ]

  name   = coalesce(var.name, random_pet.pet.id)
  tags   = merge(var.tags, map("terraform", true))
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
}

data aws_availability_zones availability_zones {
  state = "available"
}

data aws_eks_cluster eks_cluster {
  name = module.eks.cluster_id
}

data aws_eks_cluster_auth eks_cluster_auth {
  name = module.eks.cluster_id
}

data aws_iam_user iam_user {
  count = length(var.users)

  user_name = element(var.users, count.index)
}

provider kubernetes {
  version = "~> 1.11"

  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

resource random_pet pet {}

module vpc {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.32.0"

  azs                     = data.aws_availability_zones.availability_zones.names
  cidr                    = var.cidr_block
  create_vpc              = var.vpc_id != "" ? false : true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  map_public_ip_on_launch = var.map_public_ip_on_launch
  name                    = local.name

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]

  private_subnet_tags = map(
    format("kubernetes.io/cluster/%s", local.name), "shared",
    "kubernetes.io/role/internal-elb", "1"
  )

  public_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  public_subnet_tags = map(
    format("kubernetes.io/cluster/%s", local.name), "shared",
    "kubernetes.io/role/elb", "1"
  )

  single_nat_gateway = true
  tags               = local.tags
}

module eks {
  source  = "terraform-aws-modules/eks/aws"
  version = "11.0.0"

  cluster_name       = local.name
  cluster_version    = var.cluster_version
  config_output_path = format("%s/.kube/config", pathexpand("~"))
  map_users          = local.map_users

  // TODO(jasonwalsh): allow user to specify subnets or use subnets from VPC module
  subnets = module.vpc.public_subnets
  tags    = local.tags
  vpc_id  = local.vpc_id

  worker_groups = [
    {
      asg_max_size  = var.max_size
      instance_type = var.instance_type
    }
  ]
}
