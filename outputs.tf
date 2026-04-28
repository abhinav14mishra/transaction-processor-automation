#############################################
# outputs.tf
#############################################

output "vpc_id" {
  value = aws_vpc.main.id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "step_function_arn" {
  value = aws_sfn_state_machine.workflow.arn
}

output "input_bucket" {
  value = aws_s3_bucket.transactions.bucket
}