/* resource "aws_instance" "Tokyo_main" {
  ami           = "ami-023ff3d4ab11b2525"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Tokyo_public_subnet_1.id
  security_groups = [aws_security_group.tokyo_port80.id]
  key_name = "Armageddon"

  tags = {
    Name = "Tokyo Mainframe"
  }
}

resource "aws_security_group" "tokyo_port80" {
  name_prefix = "tokyo_port80_"
  
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
}
 */

resource "aws_launch_template" "tokyo-80" {
  name_prefix   = "tokyo-80"
  image_id      = "ami-023ff3d4ab11b2525"  
  instance_type = "t2.micro"

  key_name = "Armageddon"

  vpc_security_group_ids = [aws_security_group.tokyo_alb_sg.id]

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
      Name    = "Tokyo-80"
      Service = "Tokyo-Medical-Center"
      Owner   = "Men-of-AWS"
      Planet  = "Earth"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}