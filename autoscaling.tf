resource "aws_autoscaling_group" "asg" {
  name = "csye6225-asg-spring2023"

  tag {
    key                 = "webapp"
    value               = "asg_instance"
    propagate_at_launch = true
  }
  launch_template {
    id      = aws_launch_template.auto_scaling_template.id
    version = "$Latest"
  }
  target_group_arns = [
    aws_lb_target_group.target_group.arn
  ]
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]

  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  health_check_grace_period = 50
  health_check_type         = "EC2"
  default_cooldown          = 60
  wait_for_capacity_timeout = "5m"
}

resource "aws_autoscaling_policy" "scaleup_policy" {
  name                    = "scaleup-policy"
  policy_type             = "SimpleScaling"
  adjustment_type         = "ChangeInCapacity"
  metric_aggregation_type = "Average"
  cooldown                = 60
  scaling_adjustment      = 1
  autoscaling_group_name  = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scaleup_alarm" {
  alarm_name          = "scaleup-alarm"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  evaluation_periods  = 1
  period              = 60
  threshold           = 5
  alarm_actions       = [aws_autoscaling_policy.scaleup_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scaledown_policy" {
  name                    = "scaledown-policy"
  policy_type             = "SimpleScaling"
  adjustment_type         = "ChangeInCapacity"
  metric_aggregation_type = "Average"
  scaling_adjustment      = -1
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "scaledown_alarm" {
  alarm_name          = "scaledown-alarm"
  comparison_operator = "LessThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  evaluation_periods  = 1
  period              = 60
  threshold           = 4
  alarm_actions       = [aws_autoscaling_policy.scaledown_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}