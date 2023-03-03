resource "aws_key_pair" "deployer" {
  key_name   = "ec2-dp"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOieqgYIe73El4FwioV4t4bio/GPC6pf2XBY0icTBVedooIkBbr8YmoRHPq6G1IiutnO5DT1cfmrf65saZlhioeLBohqPJJniTcVttymJBj+4jggTeDrxE4TmTMYA4NSe1y6aBGFnfcVxpljDpsZf1xW7v/nPKdz2Qd/+OFNwojosdZKmPWFXd5mmKh6O0nmcEQpXDb2dDy+lCVhGdC4v3egqhl8guzRu7kGO1E/strzOk4ZYCXuRYWlNJd4h1Tl9AlyTbx7RukFVTRAQC8SeWBkTMTB5u2bH1tAlYYEHveA4YMIiVsrgTJ9zsGkiousNrEnyFKChsmnB/jdEpprk7fCCK+U3issbYivul6IoQvTUmg3CHQwM1M2gqsDcqdCIkK4pxrpQj3/WH8aOLHvalsbDK2UG8VZiklGSAcIAoWKJVW+wenyvCNA33IbUIvu76sjdS0Jonvcjl2go/eaJJUWwmBgZ+FMWcvcKjaMhvgji/2rz6PozYUVvkyS0YILU= rishikagurram@Rishikas-MacBook-Air.local"
}
resource "aws_instance" "ec2_instance" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public_subnets[0].id
  vpc_security_group_ids  = [aws_security_group.security_group.id]
  key_name                = aws_key_pair.deployer.key_name
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
    Environment="DB_HOST=${element(split(":", aws_db_instance.main.endpoint), 0)}"
    Environment="DB_USER=${aws_db_instance.main.username}"
    Environment="DB_PASSWORD=${aws_db_instance.main.password}"
    Environment="DB_DATABASE=${aws_db_instance.main.db_name}"
    Environment="AWS_BUCKET_NAME=${aws_s3_bucket.private.id}"
    Environment="AWS_REGION=${var.region}"
    Environment="AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}"
    Environment="AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}"
    Type=simple
    User=ec2-user
    WorkingDirectory=/home/ec2-user
    ExecStart=/usr/bin/make runserver
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target" > /etc/systemd/system/webapp.service
    sudo systemctl daemon-reload
    sudo systemctl start webapp.service
    sudo systemctl enable webapp.service
  EOF
}

resource "aws_iam_instance_profile" "EC2-CSYE6225_instance_profile" {
  name = "EC2-CSYE6225_Role_Instance_profile"
  role = aws_iam_role.EC2_CSYE6225.name
}