# based on https://www.terraform.io/docs/configuration/interpolation.html#using-templates-with-count

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "num_instances" {
  default = 2
}

data "template_file" "web_init" {
  # Render the template once for each instance
  count    = "${var.num_instances}"
  template = "${file("${path.module}/web_init.tpl.sh")}"
  vars {
    # count.index tells us the index of the instance we are rendering
    hostname = "host-${count.index}.example.com"
  }
}

resource "aws_instance" "web" {
  # Create one instance for each hostname
  count         = "${var.num_instances}"
  ami           = "ami-6f198a0c"
  instance_type = "t2.micro"
  key_name      = "yodo2"

  # Pass each instance its corresponding template_file
  user_data     = "${data.template_file.web_init.*.rendered[count.index]}"
}

output "public_dns" {
  value = "${aws_instance.web.*.public_dns}"
}
