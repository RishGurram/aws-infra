resource "aws_instance" "ec2_instance" {
  ami                     = var.ami
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public_subnets[0].id
  vpc_security_group_ids  = [aws_security_group.application.id]
  disable_api_termination = true
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