# Launch template - this is a template for the EC2 instances that will be launched by the auto-scaling group
resource "aws_launch_template" "this" {
  name = "webserver-template"

  image_id      = "ami-0584590e5f0e97daa" # Debian AMI ID for eu-central-1
  instance_type = "t2.micro"              # free tier eligible instance type

  user_data = filebase64("webserver.sh")

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webserver-instance"
    }
  }
}

# Auto-scaling group - this will launch and manage the EC2 instances
resource "aws_autoscaling_group" "this" {
  desired_capacity = 2
  min_size         = 1
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id,
    aws_subnet.subnet_c.id
  ]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-webserver-instances"
    propagate_at_launch = true
  }
}

# Load Balancer - this will distribute traffic across the EC2 instances
resource "aws_lb" "this" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]

  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id,
    aws_subnet.public_subnet_c.id
  ]

  tags = {
    Name = "lb-webserver"
  }
}

# Target Group - this will route requests to the EC2 instances
resource "aws_lb_target_group" "this" {
  name     = "webserver-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "webserver-targets"
  }
}

# Listener - this will listen for incoming traffic on the load balancer
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# Attach the Auto Scaling group to the Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}