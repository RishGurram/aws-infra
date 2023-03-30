resource "aws_iam_role" "EC2_CSYE6225" {
  name = "EC2_CSYE6225"
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

resource "aws_iam_policy" "WebAppS3" {
  name = "WebAppS3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.private.id}",
          "arn:aws:s3:::${aws_s3_bucket.private.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "WebAppS3_policy_attachment" {
  policy_arn = aws_iam_policy.WebAppS3.arn
  role       = aws_iam_role.EC2_CSYE6225.name
}
resource "aws_iam_policy" "CloudWatch" {
  name = "CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        Effect = "Allow"
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ],
        Resource = [
          "arn:aws:ssm:::parameter/AmazonCloudWatch-*"
          ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "CloudWatch_policy_attachment" {
  policy_arn = aws_iam_policy.CloudWatch.arn
  role       = aws_iam_role.EC2_CSYE6225.name
}
