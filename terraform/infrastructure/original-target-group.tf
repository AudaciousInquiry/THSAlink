locals {
  api_port = "9440" // original = 9440
  consumer_port = "9441" // original = 9441
  datastore_port = "9442" // aka "hapi" original = 9442
  keycloak_port = "12443" // original = 8443
  cqf_port = "9443" // original = 9443
  web_port = "11443" // original = 443
}
/*
 TARGET GROUP - START
*/

resource "aws_lb_target_group" "tfer--thsa-dashboard" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200-304"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-dashboard"
  port                              = "443"
  protocol                          = "HTTPS"
  protocol_version                  = "HTTP1"
  slow_start                        = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-link-api" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"

  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-link-api"
  port                              = "9090"
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-link-consumer" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"
  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-link-consumer"
  port                              = "9091"
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-link-cqf" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"
  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-link-cqf"
  port                              = "9093"
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-link-hapi" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"
  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-link-hapi"
  port                              = "9092"
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-link-keycloak" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"
  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-link-keycloak"
  port                              = "8443"
  preserve_client_ip                = "true"
  protocol                          = "TLS"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-link-web" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"
  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-link-web"
  port                              = "80"
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_target_group" "tfer--thsa-saner-app-group" {
  connection_termination = "false"
  deregistration_delay   = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = "10"
    unhealthy_threshold = "3"
  }

  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "thsa-saner-app-group"
  port                              = "443"
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = "false"

  stickiness {
    cookie_duration = "0"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "instance"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}
/*
 TARGET GROUP - END
*/

/*
 LOAD BALANCER LISTENER - START
*/
resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-dashboard" {
  // TODO - why did this have a different cert resource, its the same as the others....
  certificate_arn = "arn:aws:acm:us-east-1:630722759411:certificate/6db73f72-6c90-4068-8624-ab0a43182271"

  default_action {
    order            = "1"
    target_group_arn = aws_lb_target_group.tfer--thsa-dashboard.arn
    type             = "forward"
  }

  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:630722759411:loadbalancer/app/thsa-alb/82b4c9b383f100ea"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-link-consumer" {
  certificate_arn = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn

  default_action {
    target_group_arn = aws_lb_target_group.tfer--thsa-link-consumer.arn
    type             = "forward"
  }

  load_balancer_arn = var.api_loadbalancer_arn
  port              = local.consumer_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-link-hapi" {
  certificate_arn = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn

  default_action {
    target_group_arn = aws_lb_target_group.tfer--thsa-link-hapi.arn
    type             = "forward"
  }

  load_balancer_arn = var.api_loadbalancer_arn
  port              = local.datastore_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-link-keycloak" {
  certificate_arn = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn

  default_action {
    target_group_arn = aws_lb_target_group.tfer--thsa-link-keycloak.arn
    type             = "forward"
  }

  load_balancer_arn = var.api_loadbalancer_arn
  port              = local.keycloak_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-link-api" {
  certificate_arn = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn

  default_action {
    target_group_arn = aws_lb_target_group.tfer--thsa-link-api.arn
    type             = "forward"
  }

  load_balancer_arn = var.api_loadbalancer_arn
  port              = local.api_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-link-cqf" {
  certificate_arn = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn

  default_action {
    target_group_arn = aws_lb_target_group.tfer--thsa-link-cqf.arn
    type             = "forward"
  }

  load_balancer_arn = var.api_loadbalancer_arn
  port              = local.cqf_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener" "tfer--aws_lb_listener--thsa-link-web" {
  certificate_arn = aws_acm_certificate.thsa1_sanerproject_org_exp_2024.arn

  default_action {
    target_group_arn = aws_lb_target_group.tfer--thsa-link-web.arn
    type             = "forward"
  }

  load_balancer_arn = var.api_loadbalancer_arn
  port              = local.web_port
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}
/*
 LOAD BALANCER LISTENER - END
*/

/*
 LISTENER RULES - START
*/
resource "aws_lb_listener_rule" "tfer--aws_lb_listener_rule--rule1" {
  action {
    order            = "1"
    target_group_arn = aws_lb_target_group.tfer--thsa-dashboard.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["dashboard.sanerproject.org"]
    }
  }

  listener_arn = aws_lb_listener.tfer--aws_lb_listener--thsa-dashboard.arn
  priority     = "1"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

resource "aws_lb_listener_rule" "tfer--aws_lb_listener_rule--rule2" {
  action {
    order            = "1"
    target_group_arn =  aws_lb_target_group.tfer--thsa-dashboard.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = ["thsa.sanerproject.org"]
    }
  }

  listener_arn = aws_lb_listener.tfer--aws_lb_listener--thsa-dashboard.arn
  priority     = "2"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}
/*
 LISTENER RULES - END
*/

resource "aws_lb_target_group_attachment" "tfer--thsa-dashboard-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-dashboard.arn
  target_id        = var.esri_ec2_instance_id
}

/*
// NOTE - commenting these out 14-Dec-2023 as the original EC2 instance
//        has been terminated.
resource "aws_lb_target_group_attachment" "tfer--thsa-link-api-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-link-api.arn
  target_id        = var.legacy_link_ec2_server
}

resource "aws_lb_target_group_attachment" "tfer--thsa-link-consumer-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-link-consumer.arn
  target_id        = var.legacy_link_ec2_server
}

resource "aws_lb_target_group_attachment" "tfer--thsa-link-cqf-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-link-cqf.arn
  target_id        = var.legacy_link_ec2_server
}

resource "aws_lb_target_group_attachment" "tfer--thsa-link-hapi-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-link-hapi.arn
  target_id        = var.legacy_link_ec2_server
}

resource "aws_lb_target_group_attachment" "tfer--thsa-link-keycloak-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-link-keycloak.arn
  target_id        = var.legacy_link_ec2_server
}

resource "aws_lb_target_group_attachment" "tfer--thsa-link-web-groupattachment" {
  target_group_arn = aws_lb_target_group.tfer--thsa-link-web.arn
  target_id        = var.legacy_link_ec2_server
}
*/

// ALL THE PREVIOUSLY USED IMPORTS
/*
import {
  to = aws_lb_target_group.tfer--thsa-dashboard
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-dashboard/93a44352c57cc1ab"
}

import {
  to =aws_lb_target_group.tfer--thsa-link-api
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-link-api/69798b6d3679045b"
}

import {
  to = aws_lb_target_group.tfer--thsa-link-consumer
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-link-consumer/2635354b5d8002e7"
}

import {
  to = aws_lb_target_group.tfer--thsa-link-cqf
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-link-cqf/6c4d0b2712abb3af"
}

import {
  to = aws_lb_target_group.tfer--thsa-link-hapi
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-link-hapi/e4f62eaafd4f0f8b"
}

import {
  to = aws_lb_target_group.tfer--thsa-link-keycloak
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-link-keycloak/0fff3d4dc3010ff4"
}

import {
  to = aws_lb_target_group.tfer--thsa-link-web
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-link-web/4951be91bbbfd74c"
}

import {
  to = aws_lb_target_group.tfer--thsa-saner-app-group
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:targetgroup/thsa-saner-app-group/1e2ba9a1bdc6277c"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-dashboard
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/app/thsa-alb/82b4c9b383f100ea/59771a0983446514"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-link-consumer
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/net/thsa-app-lb/ce8ee245b0830249/6513966df6403be3"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-link-hapi
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/net/thsa-app-lb/ce8ee245b0830249/88d8f312971977f5"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-link-keycloak
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/net/thsa-app-lb/ce8ee245b0830249/8bcb065a07aff3b2"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-link-api
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/net/thsa-app-lb/ce8ee245b0830249/d63caba41fe00ff9"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-link-cqf
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/net/thsa-app-lb/ce8ee245b0830249/e44b73686bf033d1"
}

import {
  to = aws_lb_listener.tfer--aws_lb_listener--thsa-link-web
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener/net/thsa-app-lb/ce8ee245b0830249/fbb3e2c1980141f9"
}

import {
  to = aws_lb_listener_rule.tfer--aws_lb_listener_rule--rule1
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener-rule/app/thsa-alb/82b4c9b383f100ea/59771a0983446514/1fe191964f03400f"
}

import {
  to = aws_lb_listener_rule.tfer--aws_lb_listener_rule--rule2
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:listener-rule/app/thsa-alb/82b4c9b383f100ea/59771a0983446514/d64605d665d9c3bd"
}
*/