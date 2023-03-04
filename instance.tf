resource "aws_instance" "ec2_instance" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public_subnets[0].id
  vpc_security_group_ids  = [aws_security_group.security_group.id]
  disable_api_termination = false
  depends_on = [
    aws_security_group.security_group
  ]
  root_block_device {
    volume_size = var.instance_volume_size
    volume_type = var.instance_volume_type
  }
  iam_instance_profile = aws_iam_instance_profile.EC2-CSYE6225_instance_profile.name
  tags = {
    Name = "Webapp Instance"
  }
  user_data = <<-EOF
    #!/bin/bash
    echo "[Unit]
    Description=Webapp Service
    After=network.target

    [Service]
    Environment="DB_HOST=${aws_db_instance.main.address}"
    Environment="DB_USER=${aws_db_instance.main.username}"
    Environment="DB_PASSWORD=${aws_db_instance.main.password}"
    Environment="DB_DATABASE=${aws_db_instance.main.db_name}"
    Environment="S3_BUCKET_NAME=${aws_s3_bucket.private.id}"
    Type=simple
    User=ec2-user
    WorkingDirectory=/home/ec2-user/webapp
    ExecStart=/usr/bin/uvicorn main:app --reload --workers 4 --host 0.0.0.0 --port 8001
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target" > /etc/systemd/system/webapp.service
    sudo systemctl daemon-reload
    sudo systemctl restart webapp.service
  EOF
}

resource "aws_iam_instance_profile" "EC2-CSYE6225_instance_profile" {
  name = "EC2-CSYE6225_Role_Instance_profile"
  role = aws_iam_role.EC2_CSYE6225.name
}