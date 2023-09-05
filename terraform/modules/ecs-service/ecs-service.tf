resource "aws_ecs_service" "ecs_service" {
    name = "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}"
    cluster = var.ecs_cluster_id
    task_definition = var.ecs_task_cqf_arn

    network_configuration {
        subnets = var.subnets
        security_groups = var.security_groups
        assign_public_ip = false
    }

    deployment_circuit_breaker {
        enable   = "true"
        rollback = "true"
    }

    deployment_controller {
        type = "ECS"
    }

    deployment_maximum_percent = "200"
    deployment_minimum_healthy_percent = "100"
    desired_count = "1"
    enable_ecs_managed_tags = "true"
    enable_execute_command = "false"
    health_check_grace_period_seconds  = "0"
    launch_type = "FARGATE"
    platform_version = "LATEST"
    scheduling_strategy = "REPLICA"

    dynamic "load_balancer" {
        for_each = var.target_group != null ? [1] : []
        content {
            container_name = "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}"
            container_port = var.container_port
            target_group_arn = var.target_group.arn
        }
    }

    service_registries {
        registry_arn = var.service_discovery_arn
        container_name = "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}"
    }

    dynamic "service_connect_configuration" {
        for_each = var.service_connect != false ? [1] : []
        content {
            enabled = true
            namespace = "${var.environment}-${var.customer}-${var.project_code}"
            service {
                port_name = "${var.environment}-${var.customer}-${var.project_code}-${var.application_code}-tcp"
                client_alias {
                    port = var.container_port
                }
            }
        }
    }
}