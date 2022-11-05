terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # backend "s3" {
  #   region         = "eu-central-1"
  #   bucket         = "terraform-state-for-MY-ORG"
  #   dynamodb_table = "terraform-state-lock"
  #   kms_key_id     = "alias/terraform-bucket-key"

  #   key     = "org-shared-state/terraform.tfstate"
  #   encrypt = true
  # }
}

# Those values are not passed as variables because sadly you need to hardcode them in "backend" above
# so let's at least keep them close to one another
# This can be avoided by using Terragrunt, but that's an adventure for another day
locals {
  aws_region                             = "eu-central-1"
  terraform_state_bucket_name            = "terraform-state-for-MY-ORG" # this bucket name needs to be unique across AWS
  terraform_state_dynamo_lock_table_name = "terraform-state-lock"
  terraform_state_kms_key_alias          = "alias/terraform-bucket-key"
}

provider "aws" {
  region = local.aws_region
}

module "terraform-backend" {
  source = "./backend"

  aws_region             = local.aws_region
  state_bucket_name      = local.terraform_state_bucket_name
  dynamo_lock_table_name = local.terraform_state_dynamo_lock_table_name
  kms_key_alias          = local.terraform_state_kms_key_alias
}
