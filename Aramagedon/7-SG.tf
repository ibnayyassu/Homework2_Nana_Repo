resource "aws_security_group" "Tokyo-TG01-SG01-80" {
  vpc_id = aws_vpc.tokyo.id
  tags = {
    name = "Tokyo-TG01-SG01-80"
  }
# Allow HTTP access from other locations
ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Access"
 }
egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
}
}

resource "aws_security_group" "Tokyo-SG02-LB01" {
  name        = "Tokyo-SG02-LB01"
  description = "Tokyo-SG02-LB01"
  vpc_id      = aws_vpc.tokyo.id

  ingress {
    description = "MyHomePage"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Tokyo-SG02-LB01"
    Service = "application1"
    Owner   = "Luke"
    Planet  = "Musafar"
  }

}

resource "aws_security_group" "Tokyo-TG02-SG01-8" {
  name        = "Tokyo-TG02-SG01-8"
  description = "Tokyo-TG02-SG01-8"
  vpc_id      = aws_vpc.tokyo.id

  ingress {
    description = "MyHomePage"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Secure"
    from_port   = 8
    to_port     = 8
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Tokyo-TG02-SG01-8"
    Service = "application1"
    Owner   = "Luke"
    Planet  = "Musafar"
  }

}
# Create security group for load balancer
resource "aws_lb_target_group" "tokyo_tg_80" {
  name     = "tokyo-target-group"
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
    Name    = "tokyo-target-group"
    Service = "tokyo"
    Owner   = "Chewbacca"
    Project = "tokyo"
  }
}

resource "aws_lb_target_group" "tokyo_tg_80" {
  name     = "tokyo_tg_80"
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
    Name    = "tokyo_tg_80"
    Service = "tokyo"
    Owner   = "Chewbacca"
    Project = "tokyo_tg_80"
  }
}
# Create application load balancer
resource "aws_lb" "tokyo_alb" {
  name               = "tokyo-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Tokyo-SG02-LB01.id]
  subnets            = [
    aws_subnet.tokyo_public_subnet_1.id,
    aws_subnet.tokyo_public_subnet_2.id 
  ]
  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "TokyoLoadBalancer"
    Service = "Multiapp"
    Owner   = "Chewbacca"
    Project = "Multiapp"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.tokyo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tokyo_tg_80.arn
  }
}

output "lb_dns_name" {
  value       = aws_lb.tokyo_alb.dns_name
  description = "The DNS name of the Armagaddeon Load Balancer."
}

# Create security group for elastic load balancer
resource "aws_security_group" "elb_sg" {
  name        = "allow_http_elb"
  description = "Allow HTTP Inbound traffic for elb"
  vpc_id      = aws_vpc.tokyo.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb"
  }
}

# Create Elastic Load Balancer
resource "aws_lb" "TokyoELB" {
  name = "TokyoELB"
  subnets = [
    aws_subnet.TokyoPublicSubnet1.id,
    aws_subnet.TokyoPublicSubnet2.id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "TokyoELB"
  }
}

# Create listner for ELB to associate to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.TokyoELB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Tokyo_tg_80.arn
  }
}