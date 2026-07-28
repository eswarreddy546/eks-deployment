module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  ##################################################
  # EKS CLUSTER
  ##################################################
  # Kubernetes Upgrade Strategy
  #
  # Current Kubernetes Version : 1.32
  # Target Kubernetes Version  : 1.33
  #
  # Note:
  # EKS Platform Version (eks.xx) is managed
  # automatically by AWS and cannot be configured
  # in Terraform.
  ##################################################

  name               = local.common_name_suffix
  kubernetes_version = var.eks_version

  ##################################################
  # EKS ADD-ONS
  ##################################################

  addons = {
    coredns = {}

    eks-pod-identity-agent = {
      before_compute = true
    }

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }

    metrics-server = {}
  }

  ##################################################
  # CLUSTER CONFIGURATION
  ##################################################

  endpoint_public_access                   = false
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_node_security_group = false
  create_security_group      = false

  node_security_group_id = local.eks_node_sg_id
  security_group_id      = local.eks_control_plane_sg_id

  ##################################################
  # EKS MANAGED NODE GROUPS
  ##################################################

  eks_managed_node_groups = {

    ##################################################
    # BLUE NODE GROUP (CURRENT PRODUCTION)
    ##################################################
    #
    # Kubernetes Version : 1.32
    #
    # Production workloads are currently running here.
    ##################################################

    blue = {
      create             = var.enable_blue
      ami_type           = "AL2023_x86_64_STANDARD"
      kubernetes_version = var.eks_nodegroup_blue_version



      instance_types = ["t3.small"]

        min_size     = 1
        desired_size = 1
        max_size     = 2

      # instance_types = ["t3.small"]

      # min_size     = 2
      # desired_size = 2
      # max_size     = 10

      iam_role_additional_policies = {
        amazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        amazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      labels = {
        nodegroup = "blue"
      }
    }

    ##################################################
    # GREEN NODE GROUP (UPGRADE TARGET)
    ##################################################
    #
    # Step 1:
    # Create Green Node Group with Kubernetes 1.32
    #
    # Step 2:
    # Upgrade Control Plane from 1.32 -> 1.33
    #
    # Step 3:
    # Upgrade Green Node Group to Kubernetes 1.33
    #
    # Step 4:
    # Validate Green Environment
    #
    # Step 5:
    # Remove NoSchedule taint
    #
    # Step 6:
    # Cordon & Drain Blue Nodes
    #
    # Step 7:
    # Kubernetes recreates the application Pods
    # on the Green Node Group.
    #
    # Step 8:
    # Delete the Blue Node Group.
    ##################################################

    green = {
      create             = var.enable_green
      ami_type           = "AL2023_x86_64_STANDARD"
      kubernetes_version = var.eks_nodegroup_green_version

    

    instance_types = ["t3.small"]

      min_size     = 1
      desired_size = 1
      max_size     = 2
    # instance_types = ["t3.small"]

    #   min_size     = 2
    #   desired_size = 2
    #   max_size     = 10

      iam_role_additional_policies = {
        amazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        amazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      # Prevent workloads from scheduling
      # until validation is completed.
      taints = {
        upgrade = {
          key    = "upgrade"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      labels = {
        nodegroup = "green"
      }
    }
  }

  ##################################################
  # TAGS
  ##################################################

  tags = merge(
    local.common_tags,
    {
      Name = local.common_name_suffix
    }
  )
}