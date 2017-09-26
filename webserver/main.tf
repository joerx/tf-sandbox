# Create a new ec2 instance and sets it up as a web server. static web assets will be copied in
# from an existing S3 bucket.

# Define the instance along with an instance profile for S3 access and a bootstrap script to 
# install httpd and copy some static files to serve.
resource "aws_instance" "example" {

    ami = "${lookup(var.aws_ami_ids, var.aws_region)}"
    instance_type = "t2.micro"
    key_name = "${var.keypair_name}"

    vpc_security_group_ids = [
      "${aws_security_group.webserver_security_group.id}"
    ]

    iam_instance_profile = "${aws_iam_instance_profile.webserver_instance_profile.id}"
    user_data = "${data.template_file.bootstrap_script.rendered}"
}

# Elastic IP, not really necessary in this case, but might as well. 
resource "aws_eip" "eip" {
    instance = "${aws_instance.example.id}"
    depends_on = ["aws_instance.example"]
}

# Getting a working instance profile is a bit complicated. When done via AWS console most of the 
# gruntwork is done in the background, but here we have to deal with all the gory details:
# (Luckily TF will at least help creating everything in the correct sequence)

# 1. Define an IAM role to use with the instance profile. We also need to allow EC2 to assume this 
# role which is done through the policy referenced by `assume_role_policy` (and defined later)
resource "aws_iam_role" "s3_access" {
  name = "WebserverS3AccessRole"
  assume_role_policy = "${data.aws_iam_policy_document.webserver_assume_role_policy.json}"
}

# 2. The policy resource, but the actual policy document is provided as data source (though we 
# could also just provide the JSON inline)
resource "aws_iam_policy" "s3_access_policy" {
  name = "WebserverS3AccessPolicy"
  policy = "${data.aws_iam_policy_document.s3_access_policy_document.json}"
}

# 3. The actual policy document that will be attached to the policy above
data "aws_iam_policy_document" "s3_access_policy_document" {
  statement {
    actions = ["s3:*"]
    resources = ["*"]
    effect = "Allow"
  }
}

# 4. Attach the policy to the role we defined earlier
resource "aws_iam_policy_attachment" "attach_s3_access_to_webserver" {
  name = "AttachS3AccessToWebserverRole"
  roles = ["${aws_iam_role.s3_access.name}"]
  policy_arn = "${aws_iam_policy.s3_access_policy.arn}"
}

# 5. The policy document to establish a trust relationship between our role and EC2 - aka
# we grant EC2 permission to assume our role.
data "aws_iam_policy_document" "webserver_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 6. Finally we can create our EC2 instance profile referencing the role we defined in step 1.
resource "aws_iam_instance_profile" "webserver_instance_profile" {
  name = "WebserverInstanceProfile"
  role = "${aws_iam_role.s3_access.id}"
}

# Security group to open port 22 and 80 to the world. Note that the egress rules won't be created 
# automatically, so we need to define one explicitly.
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

# The bootstrap script that will set up httpd and copy static files from S3 to the instance.
data "template_file" "bootstrap_script" {
  template = "${file("bootstrap.sh")}"

  vars = {
    aws_region = "${var.aws_region}"
    source_bucket_name = "${var.source_bucket_name}"
  }
}

# Output the public IP and DNS names for quick testing.
output "ip" {
    value = "${aws_eip.eip.public_ip}"
}

output "public_dns" {
    value = "${aws_instance.example.public_dns}"
}
