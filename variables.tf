# variables.tf

# Define the variables that will be used in the configuration

variable "aws_access_key" {
    description = "IAM public access key"
}

variable "aws_secret_key" {
    description = "IAM secret access key"
}

variable "aws_region" {
    description = "The AWS region things are created in"
    default = "us-east-1"
}

variable "ecs_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "gonchQuestECSTaskExecutionRole"
}

# variable "ecs_auto_scale_role_name" {
#     description = "ECS auto scale role name"
#     default = "gonchQuestECSAutoScaleRole"
# }

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = "2"
}

variable "app_image" {
    description = "Docker image to run in the ECS cluster"
    default = "node:latest"
}

variable "app_port" {
    description = "Port exposed by the docker image to redirect traffic to, in this case express"
    default = 3000
}

variable "app_count" {
    description = "Number of docker containers to run"
    default = 1
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
    description = "Fargate CPU units (where 1 vCPU = 1024 CPU units)"
    default = "1024"
}

variable "fargate_memory" {
    description = "Fargate provisioned memory (in MiB)"
    default = "2048"
}

variable "domain" {
    description = "Domain name to use for the ACM certificate"
    default = "gonchquest.com"  
}