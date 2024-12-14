#Armageddon Project Final
provider "aws" {
  region = "Hong_Kong-ap-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# this  makes  vpc.id which is aws_vpc.app1.id
resource "aws_vpc" "CLass6_Armageddon" {
  cidr_block = "10.121.0.0/16"

  tags = {
    Name = "Class6_Armageddon"
    Service = "application1"
    Owner = "Geronimo"
    Planet = "Galvatron"
  }
}

#These are   for  public

resource "aws_subnet" "public-Hong_Kong-ap-east-1a" {
  vpc_id                  = aws_vpc.Class6_Armageddon.id
  cidr_block              = "10.121.1.0/24"
  availability_zone       = "Hong_Kong-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-Hong_kong-east-1a"
    Service = "application1"
    Owner   = "Geronimo"
    Planet  = "Galvatron"
  }
}

resource "aws_subnet" "public-Hong_Kong-east-1b" {
  vpc_id                  = aws_vpc.Class6_Armageddon.id
  cidr_block              = "10.121.2.0/24"
  availability_zone       = "Hong_Kong-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-Hong_Kong-east-1b"
    Service = "application1"
    Owner   = "Geronimo"
    Planet  = "Galvatron"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Class6_Armageddon.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Class6_Armageddon.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private-Hong_Kong-ap east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-Hong_Kong-ap-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private-Hong_Kong-ap-east-1c" {
  subnet_id      = aws_subnet.private-Hong_Kong-ap-east-1c.id
  route_table_id = aws_route_table.private.id
}


#public

resource "aws_route_table_association" "public-Hong_Kong-ap-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-Hong-Kong-ap-east-1b" {
  subnet_id      = aws_subnet.public-hong_Kong-ap-east-1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-Hong_Kong-ap-east-1c" {
  subnet_id      = aws_subnet.public-hong_Kong-ap-east-1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "Class6_Armageddon-TG01-SG01-80" {
  name        = "Class6_Armageddon-TG01-SG01-80"
  description = "Class6_Armageddon-TG01-SG01-80"
  vpc_id      = aws_vpc.Class6_Armageddon.id

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

  tags {
    Name    = "Class6_Armageddon-TG01-SG01-80"
    Service = "application1"
    Owner   = "Geronimo"
    Planet  = "Galvatron"
  }
}
resource = "aws_launch_template" ,"Class6_Armageddon_LT_80" {

  name_prefix   ="Class6_Armageddon-LT-80"
  image_id      = "ami-012967cc5a8c9f891"  
  instance_type = "t2.micro"

  key_name = "BasicLinux2"

  vpc_security_group_ids = [aws_security_group.Class6_Armageddon-TG01-SG01-80.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd

    # Get the IMDSv2 token
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    # Background the curl requests
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4 &> /tmp/local_ipv4 &
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone &> /tmp/az &
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ &> /tmp/macid &
    wait

    macid=$(cat /tmp/macid)
    local_ipv4=$(cat /tmp/local_ipv4)
    az=$(cat /tmp/az)
    vpc=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$macid/vpc-id)

    # Create HTML file
    cat <<-HTML > /var/www/html/index.html
    <!doctype html>
    <html lang="en" class="h-100">
    <head>
    <title>Details for port 80 EC2 instance</title>
    </head>
    <body>
    <div>
    <h1>Lizzo Sunday</h1>
    <h1>Lizzo entered port 80</h1>
    <p><b>Instance Name:</b> $(hostname -f) </p>
    <p><b>Instance Private Ip Address: </b> $local_ipv4</p>
    <p><b>Availability Zone: </b> $az</p>
    <p><b>Virtual Private Cloud (VPC):</b> $vpc</p>
    </div>
    </body>
    </html>
    HTML

    # Clean up the temp files
    rm -f /tmp/local_ipv4 /tmp/az /tmp/macid
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    ="Class6_Armageddon_LT_80"
      Service = "application1"
      Owner   = "Geronimo"
      Planet  = "Galvatron"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_launch_template" "Class6_Armageddon-LT-443" {
  name_prefix   = "Class6_Armageddon-LT-443"
  image_id      = "ami-012967cc5a8c9f891"  
  instance_type = "t2.micro"

  key_name = "BasicLinux2"

  vpc_security_group_ids = [aws_security_group.Class6_Armageddon-TG02-SG01-443.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd

    # Get the IMDSv2 token
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    # Background the curl requests
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4 &> /tmp/local_ipv4 &
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone &> /tmp/az &
    curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ &> /tmp/macid &
    wait

    macid=$(cat /tmp/macid)
    local_ipv4=$(cat /tmp/local_ipv4)
    az=$(cat /tmp/az)
    vpc=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$macid/vpc-id)

    # Create HTML file
    cat <<-HTML > /var/www/html/index.html
    <!doctype html>
    <html lang="en" class="h-100">
    <head>
    <title>Details for EC2 instance</title>
    </head>
    <body>
    <div>
    <h1>Lizzo is secure in port 443</h1>
    <h1>Lizzo has entered port 443</h1>
    <p><b>Instance Name:</b> $(hostname -f) </p>
    <p><b>Instance Private Ip Address: </b> $local_ipv4</p>
    <p><b>Availability Zone: </b> $az</p>
    <p><b>Virtual Private Cloud (VPC):</b> $vpc</p>
    </div>
    </body>
    </html>
    HTML

    # Clean up the temp files
    rm -f /tmp/local_ipv4 /tmp/az /tmp/macid
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "app2_Secure-443"
      Service = "application1"
      Owner   = "Geronimo"
      Planet  = "Galvatron"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "Class6_Armageddon_tg_80" {
  name     = "Class6_Armageddon-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Class6_Armageddon.id
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
    Name    = "Class6_ArmageddonTar_80getGroup"
    Service = "Class6_Armageddon"
    Owner   = "Geronimo"
    Project = "Class6_Armageddon"
  }
}

resource "aws_lb_target_group" "Class6_Armageddon_tg_443" {
  name     = "Class6_Armageddontg443"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Class6_Armageddon.id
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
    Name    = "Class6_Armageddon_tg_443"
    Service = "Class6_Armageddon"
    Owner   = "Geronimo"
    Project = "Class6_Armageddon"
  }
}

resource "aws_lb" "Class6_Armageddon_alb" {
  name               = "Class6_Armageddon-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Class6_Armageddon-sg02-LB01.id]
  subnets            = [
    aws_subnet.public-Hong_Kong-ap-east-1a.id,
    aws_subnet.public-Hong_Kong-ap-east-1b.id,
    aws_subnet.public-Hong_Kong-ap-east-1c.id
  ]
  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "Class6_ArmageddonLoadBalancer"
    Service = "Multiapp"
    Owner   = "Geronimo"
    Project = "Multiapp"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.Class6_Armageddon_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Class6_Armageddon_tg_80.arn
  }
}

resource "aws_autoscaling_group" "Class6_Armageddon_asg_80" {
  name_prefix           = "Class6_Armageddon-aut_80o-scaling-group-"
  min_size              = 3
  max_size              = 9
  desired_capacity      = 6
  vpc_zone_identifier   = [
    aws_subnet.private-Hong_Kong-ap-east-1a.id,
    aws_subnet.private-Hong_Kong-ap-east-1b.id,
    aws_subnet.private-Hong_Kong-ap-east-1c.id
  ]
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.Class6_Armageddon_tg_80.arn]

  launch_template {
    id      = aws_launch_template.Class6_Armageddon-LT-80.id
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
    value               = "Class6_Armageddon-ins_80tance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "Class6_Armageddon_scaling_policy_80" {
  name                   = "Class6_Armageddon-cpu_80-target"
  autoscaling_group_name = aws_autoscaling_group.Class6_Armageddon_asg_80.name

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
resource "aws_autoscaling_attachment" "Class6_Armageddon_asg_80_attachment" {
  autoscaling_group_name = aws_autoscaling_group.Class6_Armageddon_asg_80.name
  alb_target_group_arn   = aws_lb_target_group.Class6_Armageddon_tg_80.arn
}


resource "aws_autoscaling_group" "Class6_Armageddon_asg" {
  name_prefix           = "Class6_Armageddon-aut_80o-scaling-group-"
  min_size              = 1
  max_size              = 4
  desired_capacity      = 3
  vpc_zone_identifier   = [
    aws_subnet.private-Hong_Kong-ap-east-1a.id,
    aws_subnet.private-Hong_Kong-ap-east-1b.id,
    aws_subnet.private-Hong_Kong-ap-east-1c.id
  ]
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.Class6_Amrageddon_tg_443.arn]

  launch_template {
    id      = aws_launch_template.Class6_Amrageddon-LT-443.id
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
    value               = "Class6_Armageddon_443"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "Class6_Armageddon_scaling_policy_443" {
  name                   =Class6_Armageddon-cpu-target"
  autoscaling_group_name = "aws_autoscaling_group.Class6_Armageddon_asg.name"

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
resource "aws_autoscaling_attachment" "Class6_Armageddon_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.Class6_Armageddon_asg.name
  alb_target_group_arn   = aws_lb_target_group.Class6_Armageddon_tg_443.arn

  resource "tls_private_key" "BasicLinux2" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

data "tls_public_key" "BasicLinux2" {
  private_key_pem = tls_private_key.BasicLinux2.private_key_pem
}

output "private_key" {
  value     = tls_private_key.BasicLinux2.private_key_pem
  sensitive = true
}

output "public_key" {
  value = data.tls_public_key.BasicLinux2.public_key_openssh
}

data "aws_route53_zone" "main" {
  name         = "ibnayyassu.org"  # The domain name you want to look up
  private_zone = false
}


resource "aws_route53_record" "www" {
  zone_id = "data.aws_route53_zone.main.zone_id"
  name    = "ibnayyassu.org"
  type    = "A"

  alias {
    name                   = "aws_alb.Class6_Armageddon_alb.dns_name"
    zone_id                = "aws_alb.Class6_Armageddon_alb.zone_id"
    evaluate_target_health = "true"
  }