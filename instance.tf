resource "aws_instance" "ec2_instance" {
  ami                     = var.ami
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public_subnets[0].id
  vpc_security_group_ids  = [aws_security_group.application.id]
  disable_api_termination = true
  user_data               = <<-EOF
    #!/bin/bash
    echo "export DB_USERNAME=${var.db_username}" >> /etc/environment
    echo "export DB_PASSWORD=${var.db_password}" >> /etc/environment
    echo "export DB_HOSTNAME=${aws_db_instance.rds_instance.endpoint}" >> /etc/environment
    echo "export S3_BUCKET=${var.S3Bucket}" >> /etc/environment
  EOF
  depends_on = [
    aws_security_group.application
  ]
  root_block_device {
    volume_size = var.instance_volume_size
    volume_type = var.instance_volume_type
  }
  tags = {
    Name = "EC2 Instance"
  }
}


variable "db_username" {
  default = "csye6225"
}

variable "db_password" {
  default = "DBforcsye6225"
}