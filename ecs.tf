  # ecs.tf

resource "aws_ecs_cluster" "main" {
    name = "gonchquest-cluster"
}

# data "template_file" "gonchquest_app" {
#     template = file("./templates/ecs/gonchquest_app.json.tpl")

#     vars = {
#         app_image      = var.app_image
#         app_port       = var.app_port
#         fargate_cpu    = var.fargate_cpu
#         fargate_memory = var.fargate_memory
#         aws_region     = var.aws_region
#     }
# }

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
        "image": "${aws_ecr_repository.gonchquest_ecr_repo.repository_url}",
        "essential": true,
        "portMappings": [
          {
            "containerPort": ${var.app_port},
            "hostPort": ${var.app_port}
          }
        ],
        "memory": ${var.fargate_memory},
        "cpu": ${var.fargate_cpu}
      }
    ]
    DEFINITION
    execution_role_arn       = "${aws_iam_role.ecs_task_execution_role_name.arn}"
}

resource "aws_iam_role" "ecs_task_execution_role_name" {
    name               = var.ecs_task_execution_role_name
    assume_role_policy = "${data.aws_iam_policy_document.ecs_task_execution_role_policy_document.json}"
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

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
    policy_arn ="arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    role       = "${aws_iam_role.ecs_task_execution_role_name.name}"
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