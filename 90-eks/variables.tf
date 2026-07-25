##################################################
# Project Details
##################################################

variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "roboshop"
}

variable "environment" {
  type        = string
  description = "Environment Name"
  default     = "dev"
}

variable "zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
  default     = "Z0883794XJ2EA3764V8N"
}

variable "domain_name" {
  type        = string
  description = "Route53 Domain Name"
  default     = "eswar.fun"
}

##################################################
# EKS Cluster Version
##################################################

variable "eks_version" {
  type        = string
  description = "EKS Control Plane Kubernetes Version"
}

##################################################
# Blue Node Group Version
##################################################

variable "eks_nodegroup_blue_version" {
  type        = string
  description = "Blue Node Group Kubernetes Version"
}

##################################################
# Green Node Group Version
##################################################

variable "eks_nodegroup_green_version" {
  type        = string
  description = "Green Node Group Kubernetes Version"
}

##################################################
# Blue Node Group Enable/Disable
##################################################

variable "enable_blue" {
  type        = bool
  description = "Enable Blue Node Group"
  default     = true

}

##################################################
# Green Node Group Enable/Disable
##################################################

variable "enable_green" {
  type        = bool
  description = "Enable Green Node Group"
  default     = true

}