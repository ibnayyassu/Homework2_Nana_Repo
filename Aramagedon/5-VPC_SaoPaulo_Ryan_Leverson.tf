provider "aws" {
  region = "sa-east-1"
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
resource "aws_vpc" "Sao Paulo" {
  cidr_block = "10.121.0.0/16"

  tags = {
    Name = "Sao Paulo Medical Clinic"
    Service = "Healthcare"
    Owner = "Leverson"
    Country = "Brazil"
  }
}

#These are   for  public

resource "aws_subnet" "public-sa-east-1a" {
  vpc_id                  = aws_vpc.SaoPaulo.id
  cidr_block              = "10.121.1.0/24"
  availability_zone       = "se-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-se-east-1a"
    Service = "Healthcare"
    Owner = "Leverson"
    Country = "Brazil"
  }
}

resource "aws_subnet" "public-se-east-1b" {
  vpc_id                  = aws_vpc.SaoPaulo.id
  cidr_block              = "10.121.2.0/24"
  availability_zone       = "sa-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-sa-east-1b"
    Service = "Healthcare"
    Owner = "Leverson"
    Country = "Brazil"
  }
}


#these are for private
resource "aws_subnet" "private-sa-east-1a" {
  vpc_id            = aws_vpc.SaoPaulo.id
  cidr_block        = "10.121.11.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name    = "private-sa-east-1a"
    Service = "Healthcare"
    Owner = "Leverson"
    Country = "Brazil"
  }
}

resource "aws_subnet" "private-sa-east-1b" {
  vpc_id            = aws_vpc.SaoPaulo.id
  cidr_block        = "10.121.12.0/24"
  availability_zone = "sa-east-1b"

  tags = {
    Name    = "private-sa-east-1b"
    Service = "Healthcare"
    Owner = "Leverson"
    Country = "Brazil"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.SaoPaulo.id

  tags = {
    Name    = "SaoPaulo_IG"
   Service = "Healthcare"
    Owner = "Leverson"
    Country = "Brazil"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-sa-east-1a.id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app1.id

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
  vpc_id = aws_vpc.app1.id

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

resource "aws_route_table_association" "private-sa-east-1a" {
  subnet_id      = aws_subnet.private-sa-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-sa-east-1b" {
  subnet_id      = aws_subnet.private-sa-east-1b.id
  route_table_id = aws_route_table.private.id
}


#public

resource "aws_route_table_association" "public-sa-east-1a" {
  subnet_id      = aws_subnet.public-sa-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-sa-east-1b" {
  subnet_id      = aws_subnet.public-sa-east-1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "SaoPaulo" {
  name        = "SaoPaulo"
  description = "inbound_traffic_HTTPSaoPauloLB01"
  vpc_id      = aws_vpc.SaoPauloLB01.id

  tags = {
    Name = "SaoPaulo"
  }
}

resource "aws_security_group" "SaoPaulo" {
  name        = "SaoPaulo"
  description = "inbound_traffic_HTTPSaoPauloTG01"
  vpc_id      = aws_vpc.SaoPauloTG01.id

  tags = {
    Name = "SaoPaulo"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.SaoPaulo.id

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
  vpc_id = aws_vpc.SaoPaulo.id

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

resource "aws_route_table_association" "private-sa-east-1a" {
  subnet_id      = aws_subnet.private-sa-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-sa-east-1b" {
  subnet_id      = aws_subnet.private-sa-east-1b.id
  route_table_id = aws_route_table.private.id
}


#public

resource "aws_route_table_association" "public-sa-east-1a" {
  subnet_id      = aws_subnet.public-sa-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-sa-east-1b" {
  subnet_id      = aws_subnet.public-sa-east-1b.id
  route_table_id = aws_route_table.public.id
}


resource "aws_launch_template" "SaoPaulo_LT" {
  name_prefix   = "SaoPaulo_LT"
  image_id      = "ami-06ed60ed1369448bd"  
  instance_type = "t2.micro"

  key_name = "MyHealthcareInBrazil"

  vpc_security_group_ids = [aws_security_group.SaoPaulo-sg01-servers.id]

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
    <h1>Affordable Healthcare</h1>
    <h1>Healthcare Clinics in Brazil</h1>
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
      Name    = "SaoPaulo_LT"
      Service = "Healthcare"
      Owner   = "Leverson"
      Country  = "Brazil"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "SaoPaulo_tg" {
  name     = "SaoPaulo-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.SaoPaulo.id
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
    Name    = "SaoPauloTargetGroup"
    Service = "Healthcare"
    Owner   = "Leverson"
    Country = "Brazil"
  }
}
resource "aws_lb" "SaoPaulo_alb" {
  name               = "SaoPaulo-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SaoPaulo-sg02-LB01.id]
  subnets            = [
    aws_subnet.public-sa-east-1a.id,
    aws_subnet.public-sa-east-1b.id,
    
  ]
  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "SaoPauloLoadBalancer"
    Service = "Healthcare"
    Owner   = "Leverson"
    Country = "Brazil"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.SaoPaulo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.SaoPaulo_tg.arn
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "saopauloclinic.bz"
  statuses = ["ISSUED"]
  most_recent = true
}

output "lb_dns_name" {
  value       = aws_lb.SaoPaulo_alb.dns_name
  description = "The DNS name of the SaoPaulo Load Balancer."
}

resource "aws_autoscaling_group" "SaoPaulo_asg" {
  name_prefix           = "SaoPaulo-auto-scaling-group-"
  min_size              = 3
  max_size              = 15
  desired_capacity      = 6
  vpc_zone_identifier   = [
    aws_subnet.private-sa-east-1a.id,
    aws_subnet.private-sa-east-1b.id,
    
  ]
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.SaoPaulo_tg.arn]

  launch_template {
    id      = aws_launch_template.SaoPaulo_LT.id
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
    value               = "SaoPaulo-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "SaoPaulo_scaling_policy" {
  name                   = "SaoPaulo-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.SaoPaulo_asg.name

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
