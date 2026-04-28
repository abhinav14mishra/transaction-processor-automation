#############################################
# s3.tf
#
# PURPOSE:
# - Define the input gateway for the system
#############################################

resource "aws_s3_bucket" "transactions" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_notification" "eventbridge" {
  bucket      = aws_s3_bucket.transactions.id
  eventbridge = true
}

resource "aws_cloudwatch_event_rule" "s3_trigger" {
  name = "${var.project_name}-s3-trigger"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.transactions.bucket]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "stepfunction_target" {
  rule      = aws_cloudwatch_event_rule.s3_trigger.name
  target_id = "StartTransactionWorkflow"
  arn       = aws_sfn_state_machine.workflow.arn
  role_arn  = var.iam_role_arn
}