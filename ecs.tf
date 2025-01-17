# Configure ECS Fargate Cluster, Task Definition, and Service

resource "aws_ecs_cluster" "main" {
    name = "gonchquest-cluster"
}

data "aws_secretsmanager_secret" "sensitive_secret_word" {
  name = "gonchquest/secret_word"
}

resource "aws_ecs_task_definition" "app" {
    family                   = "gonchquest-app-task"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory
    container_definitions    = <<DEFINITION
    [
      {
        "name": "gonchquest-app",
        "image": "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_image}",
        "essential": true,
        "portMappings": [
          {
            "containerPort": ${var.app_port},
            "hostPort": ${var.app_port}
          }
        ],
        "memory": ${var.fargate_memory},
        "cpu": ${var.fargate_cpu},
        "secrets": [
          {
            "name": "SECRET_WORD",
            "valueFrom": "${data.aws_secretsmanager_secret.sensitive_secret_word.arn}"
          }
        ]
      }
    ]
    DEFINITION
    execution_role_arn = "${aws_iam_role.ecs_task_execution_role_name.arn}"
}

resource "aws_iam_role" "ecs_task_execution_role_name" {
    name = var.ecs_task_execution_role_name
    assume_role_policy = "${data.aws_iam_policy_document.ecs_task_execution_role_policy_document.json}"
    force_detach_policies = true
}

data "aws_iam_policy_document" "ecs_task_execution_role_policy_document" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
    statement {
      actions = ["secretsmanager:GetSecretValue"]
      resources = ["${data.aws_secretsmanager_secret.sensitive_secret_word.arn}"]
    }
}

resource "aws_iam_policy" "ecs_task_execution_role_policy" {
    name        = "ecs_task_execution_role_policy"
    description = "Allow ECS Task Execution Role to access Secrets Manager"
    policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Action   = "secretsmanager:GetSecretValue"
                Resource = "${data.aws_secretsmanager_secret.sensitive_secret_word.arn}"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment-aws-role" {
    policy_arn ="arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    role       = "${aws_iam_role.ecs_task_execution_role_name.name}"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
    policy_arn = aws_iam_policy.ecs_task_execution_role_policy.arn
    role       = aws_iam_role.ecs_task_execution_role_name.name
}

resource "aws_ecs_service" "main" {
    name            = "gonchquest-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.private.*.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.app.id
        container_name   = "gonchquest-app"
        container_port   = var.app_port
    }

    depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}