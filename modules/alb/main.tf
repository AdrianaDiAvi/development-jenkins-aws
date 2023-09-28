# Configure Security Group
resource "aws_security_group" "Jenkins-SG" {
  name = "Jenkins SG"
  vpc_id      = "vpc-0788b63e96852d1fd"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
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

resource "aws_security_group" "albSG" {
  name = "ALB-SG"
  vpc_id      = "vpc-0788b63e96852d1fd"
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  # Allow inbound HTTPS requests
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Application Load Balancer
resource "aws_lb" "jenkinsalb" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  internal           = true 
  subnets            = ["subnet-0261fc767bb7e521d", "subnet-018b478fd11481e94"] 
  security_groups    = [aws_security_group.albSG.id]

}
resource "aws_lb_target_group" "asg" {
  name     = "asg-TG"
  port     = var.jenkins_port
  protocol = "HTTP"
  vpc_id   = "vpc-0788b63e96852d1fd" 

  # Configure Health Check for Target Group
  health_check {
    path                = "/"
    protocol            = "HTTP"    
    matcher             = "403"
    interval            = 15
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }
}

# Configure Listeners for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkinsalb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.jenkinsalb.arn
  port              = var.alb_port_https
  protocol          = "HTTPS"
  depends_on        = [aws_lb_target_group.asg]
  certificate_arn = "arn:aws:acm:us-west-2:469964541857:certificate/1ee2916d-b707-4572-8ffa-e612d8b648c3"

  default_action {
    target_group_arn = aws_lb_target_group.asg.arn
    type = "forward"

    # Security Policy -> ELBSecurityPolicy-2016-08
    # Default SSL/TLS Certificate ->  FROM ACM / xmg-ci-aws.zpn.intel.com 
    #(arn:aws:acm:us-west-2:469964541857:certificate/1ee2916d-b707-4572-8ffa-e612d8b648c3)

  }
}

# Provides Load balancer with a listener rule resource
resource "aws_lb_listener_rule" "asg" {
  # The ARN of the listener to which to attach the rule.
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    # Optional - List of paths to match
    path_pattern {
      values = ["*"]
    }
  }

  action {
    # The type of routing action. 
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

output "jenkins_alb_dns_name" {
  value = aws_lb.jenkins_alb.dns_name
}

