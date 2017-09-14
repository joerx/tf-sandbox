provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_instance" "example" {
    ami = "${lookup(var.aws_ami_ids, var.aws_region)}"
    instance_type = "t2.micro"

    provisioner "local-exec" {
        command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
    }
}

# note that running the same config against different regions will not work as expected:
# for some reason TF will not create a new eip for the different region but try to modify the
# existing one, which will last forever.
resource "aws_eip" "eip" {
    instance = "${aws_instance.example.id}"
    depends_on = ["aws_instance.example"]
}

output "ip" {
    value = "${aws_eip.eip.public_ip}"
}
