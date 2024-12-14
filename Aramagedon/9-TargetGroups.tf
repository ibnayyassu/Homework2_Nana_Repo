resource "aws_lb_target_group" "tokyo_tg_80" {
  name     = "Tokyo-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tokyo.id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name    = "Tokyo_80_Group"
    Service = "Tokyo Midtown Medical Center"
    Owner   = "Men-of-AWS"
    Project = "Armageddon"
  }
}

# Associate the EC2 Instances with the target group
resource "aws_lb_target_group_attachment" "tokyo_tg_80_attachment" {
  target_group_arn = aws_lb_target_group.tokyo_tg_80.arn  
  target_id        = aws_launch_template.tokyo-80.id
  port             = 80
}
