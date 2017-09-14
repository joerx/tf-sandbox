variable "aws_region" {
    default = "us-east-1"
}

# AMI ids for Ubuntu Server 16.04
variable "aws_ami_ids" {
    type = "map"
    default = {
        "us-east-1" = "ami-cd0f5cb6",
        "eu-west-1" = "ami-ebd02392",
        "ap-southeast-1" = "ami-fdb8229e"
    }
}
