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

variable "subnet_cidr" {
  description = "value of the CIDR range for the subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "ecr_repo_name" {
  description = "ecr repo name"
  type = string
  default = "memory_card_game"
}