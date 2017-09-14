provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_instance" "jx-example" {
    ami = "ami-6f198a0c"
    instance_type = "t2.micro"

    provisioner "local-exec" {
        command = "echo ${aws_instance.jx-example.public_ip} > ip_address.txt"
    }
}

resource "aws_eip" "ip" {
    instance = "${aws_instance.jx-example.id}"
    depends_on = ["aws_instance.jx-example"]
}
