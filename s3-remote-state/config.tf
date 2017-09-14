terraform {
    required_version = ">= 0.9"

    backend "s3" {
        key = "meta-remote-state.tfstate"
        bucket = "tfstate-468871832330"
        region = "ap-southeast-1"
        dynamodb_table = "tfstate-lock"
    }
}
