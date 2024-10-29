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