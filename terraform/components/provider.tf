// NOTE - Necessary AWS region and profile assumed to have been set
//        in environment variables.  AWS_REGION and AWS_PROFILE
provider "aws" {}

// This makes it so that we can reference the aws region in other terraform files
// without needing to create a specific variable for it.
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}