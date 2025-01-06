# Create an Application Load Balancer (ALB) and a target group for the ALB.

resource "aws_alb" "main" {
    name        = "gonchquest-load-balancer"
    subnets         = aws_subnet.public.*.id
    security_groups = [aws_security_group.lb.id]
    internal        = false
    load_balancer_type = "application"
    idle_timeout = 60
    enable_deletion_protection = false
    enable_http2 = true
}

resource "aws_alb_target_group" "app" {
    name        = "gonchquest-target-group"
    port        = var.app_port
    protocol    = "HTTP"
    vpc_id      = aws_vpc.main.id
    target_type = "ip"
    health_check {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        path                = var.health_check_path
        unhealthy_threshold = "2"
        port = var.app_port
    }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = "${aws_acm_certificate.gonchquest.arn}"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}
