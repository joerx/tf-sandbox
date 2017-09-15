terraform {
    required_version = ">= 0.9"

    backend "s3" {
        key = "multi-instance.tfstate"
        bucket = "tfstate-468871832330"
        region = "ap-southeast-1"
        dynamodb_table = "tfstate-lock"
    }
}

provider "aws" {
    region = "${var.aws_region}"
}
