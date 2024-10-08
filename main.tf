# Create a VPC
resource "aws_vpc" "myVPC" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = "myVPC"
  }
}

# Create a public Subnet
resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.public_subnet_cidr

  tags = {
    Name = "my_public_subnet"
  }
}

# Create a private Subnet
resource "aws_subnet" "my_private_subnet1" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.aws_region_1
  tags = {
    Name = "my_private_subnet1"
  }
}

# Create a private Subnet
resource "aws_subnet" "my_private_subnet2" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.aws_region_2
  tags = {
    Name = "my_private_subnet2"
  }
}


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


# Create the S3 buckets
# terraform bucket is used to store the state file, and is being populated in the github action terraform_apply
resource "aws_s3_bucket" "memory-card-game-terraform" {
  bucket = "memory-card-game-terraform"

  tags = {
    Name        = "Memory Card Game terraform files"
    Environment = "Prod"
  }

  # Force destroy will remove the bucket even if it contains objects
  force_destroy = true
}

resource "aws_s3_bucket" "memory-card-game-frontend" {
  bucket = "memory-card-game-frontend"

  tags = {
    Name        = "Memory Card Game Frontend"
    Environment = "Prod"
  }

  # Force destroy will remove the bucket even if it contains objects
  force_destroy = true
}

# Disable Block Public Access settings
resource "aws_s3_bucket_public_access_block" "frontend_public_access_block" {
  bucket = aws_s3_bucket.memory-card-game-frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "terraform_public_access_block" {
  bucket = aws_s3_bucket.memory-card-game-terraform.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Configure the frontend S3 bucket for website hosting
resource "aws_s3_bucket_website_configuration" "memory-card-game-frontend_website" {
  bucket = aws_s3_bucket.memory-card-game-frontend.bucket

  index_document {
    suffix = "index.html"
  }

}


# Bucket policy to allow public access to the files
resource "aws_s3_bucket_policy" "frontend_public_access_policy" {
  depends_on = [ aws_s3_bucket_public_access_block.frontend_public_access_block ]
  bucket = aws_s3_bucket.memory-card-game-frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.memory-card-game-frontend.arn}/*"
      }
    ]
  })
}
resource "aws_ecr_repository" "aws_backend_ecr_repo" {
  name                  = var.ecr_repo_name
  image_tag_mutability  = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

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
  
  vpc_id     = aws_vpc.myVPC.id
  subnet_ids = [aws_subnet.my_private_subnet1.id,aws_subnet.my_private_subnet2.id ]

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