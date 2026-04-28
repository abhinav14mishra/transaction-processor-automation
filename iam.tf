#############################################
# iam.tf
#
# PURPOSE:
# - Instance profile for ephemeral EC2 instances
#############################################

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  # Extracted from the provided IAM role ARN 
  role = split("/", var.iam_role_arn)[1]
}