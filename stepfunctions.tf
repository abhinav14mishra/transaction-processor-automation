#############################################
# stepfunctions.tf
#
# PURPOSE:
# - Orchestrate ephemeral EC2 and ECS Fargate
#############################################

resource "aws_sfn_state_machine" "workflow" {
  name     = var.step_function_name
  role_arn = var.iam_role_arn

  depends_on = [
    aws_ecs_task_definition.processor
  ]

  definition = jsonencode({
    StartAt = "CreateEphemeralEC2"

    States = {
      CreateEphemeralEC2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:runInstances"
        Parameters = {
          ImageId            = var.ec2_ami
          InstanceType       = var.ec2_instance_type
          MinCount           = 1
          MaxCount           = 1
          SubnetId           = aws_subnet.main.id
          SecurityGroupIds   = [aws_security_group.main.id]
          IamInstanceProfile = { Name = aws_iam_instance_profile.ec2_profile.name }
        }
        ResultPath = "$.ec2_details"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "WorkflowFailed"
        }]
        Next = "Wait30Seconds"
      }

      Wait30Seconds = {
        Type    = "Wait"
        Seconds = 30
        Next    = "RunECSTask"
      }

      RunECSTask = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          LaunchType     = "FARGATE"
          Cluster        = aws_ecs_cluster.main.arn
          TaskDefinition = aws_ecs_task_definition.processor.arn
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = [aws_subnet.main.id]
              SecurityGroups = [aws_security_group.main.id]
              AssignPublicIp = "ENABLED"
            }
          }
        }
        ResultPath = "$.ecs_result"
        Catch = [{
          ErrorEquals = ["States.ALL"]
          ResultPath  = "$.error"
          Next        = "TerminateEC2"
        }]
        Next = "TerminateEC2"
      }

      TerminateEC2 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ec2:terminateInstances"
        Parameters = {
          "InstanceIds.$" = "$.ec2_details.Instances[*].InstanceId"
        }
        Next = "CheckFinalStatus"
      }

      CheckFinalStatus = {
        Type = "Choice"
        Choices = [{
          Variable  = "$.error"
          IsPresent = true
          Next      = "WorkflowFailed"
        }]
        Default = "WorkflowSucceeded"
      }

      WorkflowSucceeded = { Type = "Succeed" }
      WorkflowFailed    = { Type = "Fail", Error = "ProcessingError", Cause = "EC2 or ECS task failed" }
    }
  })
}