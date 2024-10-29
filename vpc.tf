# TRYING TO USE VPC MODULE instead

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.aws_azs
  private_subnets = var.aws_private_subnets
  public_subnets  = var.aws_public_subnets
  intra_subnets   = var.aws_control_plane_subnets
  enable_nat_gateway = true


 public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
 }
 
 private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
 }
}
# resource "aws_vpc" "myVPC" {
#   cidr_block       = var.vpc_cidr

#   tags = {
#     Name = "myVPC"
#   }
# }

# # Create a public Subnet
# resource "aws_subnet" "my_public_subnet" {
#   vpc_id            = aws_vpc.myVPC.id
#   cidr_block        = var.public_subnet_cidr

#   tags = {
#     Name = "my_public_subnet"
#   }
# }

# # Create a private Subnet
# resource "aws_subnet" "my_private_subnet1" {
#   vpc_id            = aws_vpc.myVPC.id
#   cidr_block        = var.private_subnet_1_cidr
#   availability_zone = var.aws_region_1
#   tags = {
#     Name = "my_private_subnet1"
#   }
# }

# # Create a private Subnet
# resource "aws_subnet" "my_private_subnet2" {
#   vpc_id            = aws_vpc.myVPC.id
#   cidr_block        = var.private_subnet_2_cidr
#   availability_zone = var.aws_region_2
#   tags = {
#     Name = "my_private_subnet2"
#   }
# }




#----------------------







# # Create a public Security Group for HTTP Traffic
# resource "aws_security_group" "public_security_group" {
#   name        = "public_security_group"
#   description = "A security group for example instances"
#   vpc_id = aws_vpc.myVPC.id
  
#   # http - requires nginx(or other webserver open)
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # ssh
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

# # Create an internet Gateway
# resource "aws_internet_gateway" "myGW" {
#   vpc_id = aws_vpc.myVPC.id

#   tags = {
#     Name = "myGW"
#   }
# }

# # Create public route-table (towards gateway)
# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.myVPC.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myGW.id
#   }
#   tags = {
#     Name = "public_rt"
#   }
# }

# # Create association from public subnet to the route-table
# resource "aws_route_table_association" "public_http_rt_assoc" {
#   subnet_id = aws_subnet.my_public_subnet.id
#   route_table_id = aws_route_table.public_rt.id
# }
