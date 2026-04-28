#############################################
# variables.tf
#
# PURPOSE:
# - Central definition for all configurable inputs
# - Updated to professional naming conventions
#############################################

# ------------------------
# General configuration
# ------------------------

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

# Proper name for the system
variable "project_name" {
  type    = string
  default = "transaction-processor"
}

# ------------------------
# Networking configuration
# ------------------------

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

# ------------------------
# EC2 (Pre-processing)
# ------------------------

variable "ec2_ami" {
  type    = string
  default = "ami-05d2d839d4f73aafb"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

# ------------------------
# ECS (Processing)
# ------------------------

variable "ecs_cluster_name" {
  type    = string
  default = "transaction-processing-cluster"
}

variable "ecs_task_cpu" {
  type    = string
  default = "256"
}

variable "ecs_task_memory" {
  type    = string
  default = "512"
}

variable "ecs_container_image" {
  type    = string
  default = "public.ecr.aws/nginx/nginx:stable"
}

# ------------------------
# IAM
# ------------------------

variable "iam_role_arn" {
  type    = string
  default = "arn:aws:iam::165742852730:role/GitHubActions-IaC-Deployer"
}

# ------------------------
# Step Functions
# ------------------------

variable "step_function_name" {
  type    = string
  default = "transaction-orchestrator-workflow"
}

# ------------------------
# S3 (Unique Name required)
# ------------------------

variable "s3_bucket_name" {
  type        = string
  default     = "2472737-transaction-input-bucket"
  description = "Unique bucket for transaction file uploads"
}