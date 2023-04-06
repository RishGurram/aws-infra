data "template_file" "userdata" {
  template = file("./userdata.sh")
  vars = {
    AWS_BUCKET_NAME = aws_s3_bucket.private.id
    DB_USERNAME     = aws_db_instance.main.username
    DB_PASSWORD     = aws_db_instance.main.password
    DB_DATABASE     = aws_db_instance.main.db_name
    DB_ADDRESS      = aws_db_instance.main.address
  }
}

data "aws_ami" "custom_ami" {
  owners      = [var.ami_owner]
  most_recent = true
}