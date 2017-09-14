provider "aws" { 
    region = "${var.aws_region}"
    version = "~> 0.1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state_bucket" {

    bucket = "tfstate-${data.aws_caller_identity.current.account_id}"
    acl = "private"

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }

    tags {
        creator = "terraform"
    }
}

resource "aws_dynamodb_table" "state_locktable" {

    name = "tfstate-lock"
    
    read_capacity = "1"
    write_capacity = "1"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags {
        creator = "terraform"
    }
}
