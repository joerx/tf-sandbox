provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_instance" "jx-example" {
    ami = "ami-6f198a0c"
    instance_type = "t2.micro"
}
