resource "aws_s3_bucket" "jenkins_s3_bucket" {
  bucket = "jenkins-s3-bucket"
  # ... other S3 bucket configurations ...
}

output "jenkins_s3_bucket_name" {
  value = aws_s3_bucket.jenkins_s3_bucket.bucket
}
