provider "aws" {
  region = "ap-southeast-2"
  alias = "Sydney"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_vpc" "Sydney1" {
  cidr_block = "10.129.0.0/16"

  tags = {
    Name = "Sydney1"
    Service = "Sydney1vpc"
    Owner = "Men of AWS"
    
  }
}

resource "aws_subnet" "public-ap-southeast-2a" {
  vpc_id                  = aws_vpc.Sydney1.id
  cidr_block              = "10.129.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-ap-southeast-2a"
    Service = "Armageddon"
    Owner   = "Men of AWS"
    
  }
}

resource "aws_subnet" "public-ap-southeast-2b" {
  vpc_id                  = aws_vpc.Sydney1.id
  cidr_block              = "10.129.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "public-ap-southeast-2b"
    Service = "Armageddon"
    Owner   = "Men of AWS"
    
  }
}

resource "aws_subnet" "private-ap-southeast-2a" {
  vpc_id            = aws_vpc.Sydney1.id
  cidr_block        = "10.129.11.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name    = "private-ap-southeast-2a"
    Service = "Armageddon"
    Owner   = "Men of AWS"
    
  }
}

resource "aws_subnet" "ap-private-southeast-2b" {
  vpc_id            = aws_vpc.Sydney1.id
  cidr_block        = "10.129.12.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name    = "private-ap-southeast-2b"
    Service = "Armageddon"
    Owner   = "Men of AWS"
    
  }
}




resource "aws_internet_gateway" "Sydney_igw" {
  vpc_id = aws_vpc.Sydney1.id

  tags = {
    Name = "Sydney_igw"
  }
}

resource "aws_default_route_table" "Sydney_Main" {
  default_route_table_id = aws_vpc.Sydney1.default_route_table_id

    tags = {
    Name = "Sydney_Main"
  }
}
resource "aws_route" "Sydney_Main" {
  route_table_id = aws_default_route_table.Sydney_Main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.Sydney_igw.id
  depends_on = [ aws_vpc.Sydney1]
}



# Elastic IP for NAT Gateway
resource "aws_eip" "Sydney_eip" {
  
  vpc = true
  provider = "aws"
}

# NAT
resource "aws_nat_gateway" "Sydney_nat" {
  allocation_id = aws_eip.Sydney_eip.id
  subnet_id     = aws_subnet.public-ap-southeast-2a.id
  provider = "aws"
  tags = {
    Name = "Sydney_nat"
  }
  depends_on = [aws_internet_gateway.Sydney_igw]
}

resource "aws_launch_template" "Sydney_LT" {
  name_prefix   = "Sydney_LT"
  image_id      = "ami-0146fc9ad419e2cfd"  
  instance_type = "t2.micro"

  key_name = "MyLinuxBox"

  vpc_security_group_ids = [aws_security_group.Sydney-sg-01.id]

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
    <h1>Malgus Clan</h1>
    <h1>Chains Broken in Ireland</h1>
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
      Name    = "Sydney_LT"
      
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "Sydney_tg" {

  name     = "Sydney-target-group"

  port     = 80

  protocol = "HTTP"

  vpc_id   = aws_vpc.Sydney1.id

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

    Name    = "SydneyTargetGroup"

    

  }

}

resource "aws_autoscaling_group" "Sydney_asg" {

  name_prefix           = "app1-auto-scaling-group-"

  min_size              = 3

  max_size              = 15

  desired_capacity      = 6

  vpc_zone_identifier   = [

    aws_subnet.private-ap-southeast-2a.id,

    aws_subnet.ap-private-southeast-2b.id,

    

  ]

  health_check_type          = "ELB"

  health_check_grace_period  = 300

  force_delete               = true

  target_group_arns          = [aws_lb_target_group.Sydney_tg.arn]


  launch_template {

    id      = aws_launch_template.Sydney_LT.id

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

    value               = "app1-instance"

    propagate_at_launch = true

  }


  tag {

    key                 = "Environment"

    value               = "Production"

    propagate_at_launch = true

  }

}
# Auto Scaling Policy

resource "aws_autoscaling_policy" "Sydney_scaling_policy" {

  name                   = "Sydney-cpu-target"

  autoscaling_group_name = aws_autoscaling_group.Sydney_asg.name


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

resource "aws_autoscaling_attachment" "Sydney_asg_attachment" {

  autoscaling_group_name = aws_autoscaling_group.Sydney_asg.name

}

resource "aws_security_group" "Sydney-sg-01" {

  name        = "Sydney-sg-01"

  description = "non-secure"

  vpc_id      = aws_vpc.Sydney1.id

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

    Name    = "Sydney-sg01-servers"

   


  }


}


# Security Groups

resource "aws_security_group" "Sydney_alb_sg" {

  name        = "Sydney_alb_sg"

  description = "Security Group for Application Load Balancer"

  vpc_id      = aws_vpc.Sydney1.id

  provider = aws.Sydney


  ingress {

    description      = "TCP"

    from_port        = 80

    to_port          = 80

    protocol         = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {

    from_port        = 0

    to_port          = 0

    protocol         = "-1"

    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {

    Name = "Sydney_alb_sg"

  }

}
resource "aws_instance" "Sydney-instance-01" {

  ami           =  "ami-0146fc9ad419e2cfd"

  instance_type = "t2.micro"

  security_groups =  [aws_security_group.Sydney-sg-01.id]

  subnet_id = aws_subnet.public-ap-southeast-2a.id


  


  tags = {

    Name = "HelloWorld"

  }

  depends_on = [aws_security_group.Sydney-sg-01]

}