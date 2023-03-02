resource "aws_db_subnet_group" "private_subnets" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnets.*.id
}

resource "aws_db_parameter_group" "postgres" {
  name   = "postgres-parameters"
  family = "postgres13"

  # parameter {
  #   name  = "shared_buffers"
  #   value = "1024MB"
  #   apply_method = "pending-reboot"
  # }

  # parameter {
  #   name  = "max_connections"
  #   value = "100"
  #   apply_method = "pending-reboot"
  # }

  tags = {
    Name = "postgres-parameters"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225-${var.profile}"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.private_subnets.id
  vpc_security_group_ids = [aws_security_group.database.id]
  db_name                = "csye6225${var.profile}"
  username               = "csye6225"
  password               = "DBforcsye6225"
  tags = {
    Name = "csye6225-rds-instance-${var.profile}"
  }
}