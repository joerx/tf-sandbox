provider "aws" {
    region = "ap-southeast-1"
}

module "consul" {
    source = "github.com/hashicorp/consul/terraform/aws"

    key_name = "yodo2"
    key_path = "/Users/joerg/.ssh/yodo2.pem"
    region = "ap-southeast-1"
    servers = "3"
}

output "consul_address" {
    value = "${module.consul.server_address}"
}
