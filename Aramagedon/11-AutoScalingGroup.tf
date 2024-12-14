resource "aws_autoscaling_group" "Tokyo_asg_80" {
  name_prefix           = "Tokyo-sg_80"
  min_size              = 1
  max_size              = 4
  desired_capacity      = 3
  vpc_zone_identifier   = [
    aws_subnet.private-ap-northeast-1a.id,  #Subnets defined for 2 AZ (ap-northeast-1a, ap-northeast-1c)
    aws_subnet.private-ap-northeast-1c.id,
  ]
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.Tokyo_tg_80.arn]

  launch_template {
    id      = aws_launch_template.tokyo-80.id     
    version = "$Latest"
  }

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  # Instance protection for launching
  initial_lifecycle_hook {
    name                  = "instance-protection-launch"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 60
    notification_metadata = "{\"key\":\"value\"}"
  }

  # Instance protection for terminating
  initial_lifecycle_hook {
    name                  = "scale-in-protection"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 300
  }

  tag {
    key                 = "Name"
    value               = "Tokyo_80"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "Tokyo_scaling_policy_80" {
  name                   = "Tokyo-cpu_80-target"
  autoscaling_group_name = aws_autoscaling_group.Tokyo_asg_80.name

  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# Enabling instance scale-in protection
resource "aws_autoscaling_attachment" "Tokyo_asg_80_attachment" {
  autoscaling_group_name = aws_autoscaling_group.Tokyo_asg_80.name
  alb_target_group_arn   = aws_lb_target_group.Tokyo_tg_80.arn
}

resource "aws_launch_configuration" "tokyo_launch_config" {
  name          = "tokyo-launch-config"
  image_id      = "ami-023ff3d4ab11b2525"  # Replace with the appropriate AMI ID for your region
  instance_type = "t2.micro"
  security_groups = [aws_security_group.tokyo_port80.id]
  user_data     = <<-EOF
    #!/bin/bash
    echo "Hello World" > /var/www/html/index.html
  EOF
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  launch_configuration = aws_launch_configuration.tokyo_launch_config.id

  health_check_type             = "EC2"
  health_check_grace_period     = 300
  force_delete                  = true
  
  tag {
    key = "Tokyo"
    value = "tokyo-instance"
    propagate_at_launch = true
  }
  
            
}
