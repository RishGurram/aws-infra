# Create an Application Load Balancer
resource "aws_lb" "application_load_balancer" {
  name               = "applicationloadbalancer"
  internal           = false
  load_balancer_type = "application"

  subnets         = [for subnet in aws_subnet.public_subnets : subnet.id]
  security_groups = [aws_security_group.load_balancer.id]

  tags = {
    webapp = "webapp_asg_instance"
  }
}

# Create a target group for the Auto Scaling Group instances
resource "aws_lb_target_group" "target_group" {
  name       = "targetgroup"
  port       = 8000
  protocol   = "HTTP"
  vpc_id     = aws_vpc.vpc.id
  slow_start = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/healthz"
    port                = "8000"
    protocol            = "HTTP"
  }
}

data "aws_acm_certificate" "issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]

}

# Attach the target group to the Application Load Balancer
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}