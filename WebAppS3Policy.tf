resource "aws_iam_role" "IAMRole" {
  name = "EC2-CSYE6225"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "WebAppS3Policy" {
  name = "WebAppS3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::${var.S3Bucket}",
          "arn:aws:s3:::${var.S3Bucket}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "IAMRoleAttachment" {
  policy_arn = aws_iam_policy.WebAppS3Policy.arn
  role       = aws_iam_role.IAMRole.name
}
