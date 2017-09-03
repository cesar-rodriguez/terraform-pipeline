terraform {
  backend "s3" {
    bucket         = "therasec-state-bucket"
    region         = "us-east-1"
    encrypt        = "true"
    acl            = "private"
    dynamodb_table = "therasec-state-bucket"
    profile        = "therasec-prod"
  }
}

variable "environment" {}
variable "trigger_change" {}

provider "aws" {
  profile = "${var.environment}"
  region  = "us-east-1"
}

data "aws_iam_account_alias" "current" {}

output "account_id" {
  value = "${data.aws_iam_account_alias.current.account_alias}"
}

output "trigger_change" {
  value = "${var.trigger_change}"
}
