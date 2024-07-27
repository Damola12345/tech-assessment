provider "aws" {
  region  = "us-east-1"
  profile = "terraform-user"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "this" {
  name = module.Globaltoye_eks.cluster_name
}

provider "kubernetes" {
  host                   = module.Globaltoye_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.Globaltoye_eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.Globaltoye_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.Globaltoye_eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

##########################################
# EKS
##########################################

module "Globaltoye_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.name
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_to_node_8833_8844 = {
      description                   = "Cluster API to Nodegroup 8833, 8844, 9933, 9944"
      protocol                      = "tcp"
      from_port                     = 8833
      to_port                       = 8844
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_cluster_to_node_9933_9944 = {
      description                   = "Cluster API to Nodegroup 9933, 9944"
      protocol                      = "tcp"
      from_port                     = 9933
      to_port                       = 9944
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_public_30334 = {
      description = "Public access to port 30334"
      protocol    = "tcp"
      from_port   = 30334
      to_port     = 30334
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # aws_lb_controller_webhook = {
    #   description                   = "Cluster API to AWS LB Controller webhook"
    #   protocol                      = "tcp"
    #   from_port                     = 9443
    #   to_port                       = 9443
    #   type                          = "ingress"
    #   source_cluster_security_group = true
    # }

    # ingress_nodes_karpenter_ports_tcp = {
    #   description                = "Karpenter readiness"
    #   protocol                   = "tcp"
    #   from_port                  = 8443
    #   to_port                    = 8443
    #   type                       = "ingress"
    #   source_node_security_group = true
    # }

  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    red = {
      name           = "red-eks-mng"
      subnet_ids     = module.vpc.private_subnets
      min_size       = 1
      max_size       = 5
      desired_size   = 1
      instance_types = ["t2.medium"]
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
        owner      = "red"
      }

      # taints = [
      #   {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # ]
      description = "EKS managed node group example launch template"


      # Remote access cannot be specified with a launch template
    },
    # blue = {
    #   name           = "blue-eks-mng"
    #   subnet_ids     = module.vpc.private_subnets
    #   min_size       = 1
    #   max_size       = 7
    #   desired_size   = 1
    #   instance_types = ["t2.xlarge"]
    #   labels = {
    #     GithubRepo = "terraform-aws-eks"
    #     GithubOrg  = "terraform-aws-modules"
    #     owner      = "blue"
    #   }

    #   # taints = [
    #   #   {
    #   #     key    = "dedicated"
    #   #     value  = "gpuGroup"
    #   #     effect = "NO_SCHEDULE"
    #   #   }
    #   # ]
    #   description = "EKS managed node group example launch template"
    # }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.name
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::431419854259:role/devops_admin"
      username = "role1"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::431419854259:role/karpenter-node-Globaltoye-prod"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]


  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::431419854259:user/terraform-user"
      username = "terraform-user"
      groups   = ["system:masters"]
    }
    # {
    #   userarn  = "arn:aws:iam::66666666666:user/user2"
    #   username = "user2"
    #   groups   = ["system:masters"]
    # },
  ]

  #   aws_auth_accounts = [
  #     "777777777777",
  #     "888888888888",
  #   ]

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

##########################################
# load_balancer_controller
##########################################

module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = module.Globaltoye_eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.Globaltoye_eks.oidc_provider_arn
  cluster_name                     = module.Globaltoye_eks.cluster_name
}



# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  # version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.Globaltoye_eks.cluster_name}"
  provider_url                  = module.Globaltoye_eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.Globaltoye_eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.26.1-eksbuild.1"
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}


module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${module.Globaltoye_eks.cluster_name}"
  provider_url                  = module.Globaltoye_eks.oidc_provider
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

# Based on https://karpenter.sh/docs/getting-started/cloudformation.yaml
resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter-policy-${module.Globaltoye_eks.cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ssm:GetParameter",
          "pricing:GetProducts"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "Karpenter"
      },
      {
        Action = "ec2:TerminateInstances"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/Name" : "*karpenter*"
          }
        }
        Effect   = "Allow"
        Resource = "*"
        Sid      = "ConditionalEC2Termination"
      },
      {
        Action   = ["iam:PassRole"]
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node.arn
      }
    ]
  })
}


resource "aws_iam_role" "karpenter_node" {
  name = "karpenter-node-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

## Instance profile for nodes to pull images, networking, SSM, etc
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "karpenter-node-${module.Globaltoye_eks.cluster_name}"
  role = aws_iam_role.karpenter_node.name
}