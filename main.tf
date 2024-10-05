provider "aws" {
    profile = "default"
    region =  "eu-north-1"
}

# Create a VPC
resource "aws_vpc" "myVPC" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = "myVPC"
  }
}

# Create a Subnet
resource "aws_subnet" "mySubnet" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.subnet_cidr

  tags = {
    Name = "mySubnet"
  }
}

# Create a Security Group for HTTP Traffic
resource "aws_security_group" "mySecurityGroup" {
  name        = "mySecurityGroup"
  description = "A security group for example instances"
  vpc_id = aws_vpc.myVPC.id
  
  # http - requires nginx(or other webserver open)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create an internet Gateway
resource "aws_internet_gateway" "myGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myGW"
  }
}

# Create public route-table (towards gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myGW.id
  }
  tags = {
    Name = "public_rt"
  }
}

# Create association from subnet to the route-table
resource "aws_route_table_association" "public_http_rt_assoc" {
  subnet_id = aws_subnet.mySubnet.id
  route_table_id = aws_route_table.public_rt.id
}


# Create the S3 bucket
resource "aws_s3_bucket" "memory-card-game-frontend" {
  bucket = "memory-card-game-frontend"

  tags = {
    Name        = "Memory Card Game Frontend"
    Environment = "Prod"
  }
}

# Disable Block Public Access settings
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.memory-card-game-frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Configure the S3 bucket for website hosting
resource "aws_s3_bucket_website_configuration" "memory-card-game-frontend_website" {
  bucket = aws_s3_bucket.memory-card-game-frontend.bucket

  index_document {
    suffix = "index.html"
  }

}


# Bucket policy to allow public access to the files
resource "aws_s3_bucket_policy" "public_access_policy" {
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



# # Create EC2 INSTANCE
# resource "aws_instance" "app_server" {
#   ami           = var.ec2_rhel_ami
#   instance_type = "t3.micro"
#   vpc_security_group_ids = [aws_security_group.mySecurityGroup.id]
#   subnet_id = aws_subnet.mySubnet.id
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