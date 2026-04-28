#############################################
# backend.tf
#
# PURPOSE:
# - Securely store Terraform state in S3
#############################################

terraform {
  backend "s3" {
    # Unique bucket name using the 2472737 prefix
    bucket         = "2472737-terraform-state-storage"
    key            = "transaction-processor/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
  }
}