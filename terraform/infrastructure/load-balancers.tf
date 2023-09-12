// Load balancer for ESRI EC2 server
resource "aws_lb" "loadbalancer--thsa-alb" {
  access_logs {
    bucket  = "esri-dashboard-lb"
    enabled = "true"
  }

  desync_mitigation_mode                      = "defensive"
  drop_invalid_header_fields                  = "false"
  enable_cross_zone_load_balancing            = "true"
  enable_deletion_protection                  = "false"
  enable_http2                                = "true"
  enable_tls_version_and_cipher_suite_headers = "false"
  enable_waf_fail_open                        = "false"
  enable_xff_client_port                      = "false"
  idle_timeout                                = "60"
  internal                                    = "false"
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  name                                        = "thsa-alb"
  preserve_host_header                        = "false"
  security_groups                             = ["sg-052a4c11ca039250a"]

  subnet_mapping {
    subnet_id = "subnet-033c5cc1aaf9bfb48"
  }

  subnet_mapping {
    subnet_id = "subnet-0b58d2d8114684fe9"
  }

  subnets                    = ["subnet-033c5cc1aaf9bfb48", "subnet-0b58d2d8114684fe9"]
  xff_header_processing_mode = "append"

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

// Load Balancer for EC2 server running API applications.
resource "aws_lb" "loadbalancer--thsa-app-lb" {
  enable_cross_zone_load_balancing = "false"
  enable_deletion_protection       = "false"
  internal                         = "false"
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  name                             = "thsa-app-lb"

  subnet_mapping {
    allocation_id = "eipalloc-01a9ddd932c061fe7"
    subnet_id     = "subnet-033c5cc1aaf9bfb48"
  }

  subnets = ["subnet-033c5cc1aaf9bfb48"]

  tags = {
    Environment = var.environment,
    CreatedBy = "terraform"
  }
}

/*
import {
  to = aws_lb.loadbalancer--thsa-alb
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:loadbalancer/app/thsa-alb/82b4c9b383f100ea"
}

import {
  to = aws_lb.loadbalancer--thsa-app-lb
  id = "arn:aws:elasticloadbalancing:us-east-1:630722759411:loadbalancer/net/thsa-app-lb/ce8ee245b0830249"
}
*/