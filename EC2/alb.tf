# Create Application Load Balancer
# terraform aws create application load balancer
resource "aws_lb" "app-lb" {
  name               = "ToyeGlobalMyAlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]

  subnet_mapping {
    subnet_id = aws_subnet.public-subnet-1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.public-subnet-2.id
  }

  enable_deletion_protection = false

  tags = {
    Name = "Application Load Balancer"
  }
}

# Create a Listener on Port 80 
# terraform aws create listener
resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg.arn
  }
  depends_on = [aws_lb_target_group.test-tg]
}

# Create Target Group
# terraform aws create target group
resource "aws_lb_target_group" "test-tg" {
  name        = "mywebserver"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    interval            = 30
    matcher             = "200,302"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}
