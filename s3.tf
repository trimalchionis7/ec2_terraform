# Create S3 bucket
resource "aws_s3_bucket" "jonnie-s3-bucket" {
    bucket = var.aws_s3_bucket

    tags = {
        Name = "s3-tf"
        Environment = "Dev"
    }
}

/*
# Configure bucket versioning
resource "aws_s3_bucket_versioning" "jonnie-s3-bucket-versioning" {
    bucket = aws_s3_bucket.jonnie-s3-bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}
*/