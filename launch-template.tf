resource "aws_launch_template" "auto_scaling_template" {
  name                    = "auto_scaling_template"
  image_id                = data.aws_ami.custom_ami.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = true
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.security_group.id]
  }

  # vpc_security_group_ids = [aws_security_group.security_group.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.EC2-CSYE6225_instance_profile.name
  }
  user_data = base64encode(data.template_file.userdata.rendered)
  depends_on = [
    aws_security_group.security_group
  ]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.instance_volume_size
      delete_on_termination = true
      volume_type           = var.instance_volume_type
    }
  }


}

