module "eks_al2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "matching_cards_game"
  # cluster_version = "1.30"
  cluster_endpoint_public_access = true
  # EKS Addons
  cluster_addons = {
    coredns                = { most_recent = true }
    eks-pod-identity-agent = { most_recent = true }
    kube-proxy             = { most_recent = true }
    vpc-cni                = { most_recent = true }
  }
  
  # vpc_id     = aws_vpc.myVPC.id
  # subnet_ids = [aws_subnet.my_private_subnet1.id,aws_subnet.my_private_subnet2.id ]
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    cards_game_EKS_wg = {
      ami_type       = "AL2_x86_64"
      instance_types = ["m5.large"]
      capacity_type = "SPOT"

      min_size = 1
      max_size = 2
      desired_size = 1
    }
  
  }

  
}




# # Create EC2 INSTANCE
# resource "aws_instance" "app_server" {
#   ami           = var.ec2_rhel_ami
#   instance_type = "t3.micro"
#   vpc_security_group_ids = [aws_security_group.public_security_group.id]
#   subnet_id = aws_subnet.my_public_subnet.id
#   associate_public_ip_address = true
 
#   tags = {
#     Name = "MyTerraformInstance"
#   }

# }

# resource "aws_eks_cluster" "example" {
#   name     = "example"
#   role_arn = aws_iam_role.example.arn

#   vpc_config {
#     subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
#   ]
# }

# output "endpoint" {
#   value = aws_eks_cluster.example.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.example.certificate_authority[0].data
# }