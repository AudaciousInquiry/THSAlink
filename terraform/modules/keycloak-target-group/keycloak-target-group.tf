resource "aws_lb_target_group" "target-group" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled = "true"
    healthy_threshold   = "5"
    interval = "30"
    port = "traffic-port"
    protocol = "TCP"
    timeout = "10"
    unhealthy_threshold = "5"
  }

  ip_address_type = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name = "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}"
  port = var.container_port
  preserve_client_ip = "false"
  protocol = "TLS"
  proxy_protocol_v2 = "false"

  stickiness {
    cookie_duration = "0"
    enabled = "false"
    type = "source_ip"
  }

  target_type = "ip"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "lb-listener" {

  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.target-group.arn
    type             = "forward"
  }

  load_balancer_arn = var.loadbalancer_arn
  port              = var.listener_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}