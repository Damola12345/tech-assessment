# Create a Launch configuration
# terraform aws launch configuration
resource "aws_launch_configuration" "asg" {
  image_id        = "ami-090fa75af13c156b4"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.id]
  user_data       = <<-EOF
                #!/bin/bash
                echo "*** Installing TOYEGlobal"
                sudo yum update -y
                sudo yum install -y httpd
                sudo systemctl start httpd.service
                sudo systemctl enable httpd.service
                echo "*** Completed Installing TOYEGlobal" >  /var/www/html/index.html
  EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
# terraform aws autoscaling group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.asg.id
  vpc_zone_identifier  = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
  min_size             = 1
  max_size             = 2

  target_group_arns = [aws_lb_target_group.test-tg.arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}
