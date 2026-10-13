resource "aws_lb_target_group" "app" {
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"
  health_check {
    path                = "/"
    matcher             = 200
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "public" {
  drop_invalid_header_fields = true
  name                       = "production-platform-alb"
  load_balancer_type         = "application"
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false
  ip_address_type            = "ipv4"
  internal                   = false
  security_groups            = [var.alb_security_group_id]
  
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
