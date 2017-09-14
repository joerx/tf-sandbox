provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_instance" "jx-example" {
    ami = "ami-fdb8229e"
    instance_type = "t2.micro"
}
