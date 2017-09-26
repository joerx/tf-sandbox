# Create a new ec2 instance and sets it up as a web server. static web assets will be copied in
# from an existing S3 bucket.

resource "aws_instance" "example" {

    ami = "${lookup(var.aws_ami_ids, var.aws_region)}"
    instance_type = "t2.micro"
    key_name = "${var.keypair_name}"

    vpc_security_group_ids = [
      "${aws_security_group.webserver_security_group.id}"
    ]

    iam_instance_profile = "${aws_iam_instance_profile.webserver_instance_profile.id}"

    provisioner "local-exec" {
        command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
    }
}

resource "aws_eip" "eip" {
    instance = "${aws_instance.example.id}"
    depends_on = ["aws_instance.example"]
}

resource "aws_iam_role" "s3_access" {
  name = "WebserverS3AccessRole"
  assume_role_policy = "${data.aws_iam_policy_document.webserver_assume_role_policy.json}"
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "WebserverS3AccessPolicy"
  policy = "${data.aws_iam_policy_document.s3_access_policy_document.json}"
}

resource "aws_iam_policy_attachment" "attach_s3_access_to_webserver" {
  name = "AttachS3AccessToWebserverRole"
  roles = ["${aws_iam_role.s3_access.name}"]
  policy_arn = "${aws_iam_policy.s3_access_policy.arn}"
}

resource "aws_iam_instance_profile" "webserver_instance_profile" {
  name = "WebserverInstanceProfile"
  role = "${aws_iam_role.s3_access.id}"
}

data "aws_iam_policy_document" "s3_access_policy_document" {
  statement {
    actions = ["s3:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "webserver_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_security_group" "webserver_security_group" {
  name = "WebServerSecurityGroup"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ip" {
    value = "${aws_eip.eip.public_ip}"
}

output "public_dns" {
    value = "${aws_instance.example.public_dns}"
}
