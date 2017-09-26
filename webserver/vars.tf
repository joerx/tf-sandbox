variable "aws_region" {
  default = "us-east-1"
}

variable "keypair_name" {
  type = "string"
}

variable "aws_ami_ids" {
    type = "map"
    default = {
        "ap-southeast-1" = "ami-fdb8229e"
    }
}
