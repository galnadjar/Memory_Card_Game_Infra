variable "ec2_rhel_ami" {
  description = "redhat ec2 t3.micro ami"
  type = string
  default = "ami-0129bfde49ddb0ed6"
}

variable "vpc_cidr" {
  description = "value of the CIDR range for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "value of the CIDR range for the subnet"
  type = string
  default = "10.0.0.0/24"
}

variable "private_subnet_1_cidr" {
  description = "value of the CIDR range for the subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_2_cidr" {
  description = "value of the CIDR range for the subnet"
  type = string
  default = "10.0.2.0/24"
}


variable "ecr_repo_name" {
  description = "ecr repo name"
  type = string
  default = "memory_card_game"
}

variable "ec2_instance_type" {
  description = "ec2 instance type"
  type = string
  default = "t3.micro"
}

variable "node_group_name" {
  description = "node group name"
  type = string
  default = "nodeg1"
}

variable "node_group_capacity" {
  description = "node group capacity"
  type = number
  default = 2
}

variable "eksctl_cluster_api_ver" {
  description = "eksctl cluster api ver"
  type = string
  default = "eksctl.io/v1alpha5"
}

variable "aws_region_1" {
  description = "aws region"
  type = string
  default = "eu-north-1a"
}

variable "aws_region_2" {
  description = "aws region"
  type = string
  default = "eu-north-1b"
}

variable "eksctl_bin" {
  description = "eksctl binary"
  type = string
  default = "eksctl"
}

variable "eks_cluster_name" {
  description = "eks cluster name"
  type = string
  default = "matching_card_game_EKS"
}