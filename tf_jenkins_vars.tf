variable "region" {
    default = "us-east-1"
}
variable "vpc_id" {
    default = "vpc-8cf379f6"
}
variable "subnet_id" {
    default = "subnet-d0dc99fe"
}

variable "ports" {
    type = "list"
    default = ["22", "8080", 0]
}

variable "ami_id" {}

variable "cidr_block_all_traffic" {
    default = "0.0.0.0/0"
}
variable "key_pair_name" {
    default = "tomcat_ec2_key"
}

variable "instance_type" {
    default = "t2.micro" 
}

variable "tags"{
    type = "list"
    default = ["Server"]
}

output "tomcat_public_ip" {
  value = "${aws_instance.TomcatServer.*.public_ip}"
}

output "tomcat_private_ip" {
  value = "${aws_instance.TomcatServer.*.private_ip}"
}

output "tomcat_public_dns" {
  value = "${aws_instance.TomcatServer.*.public_dns}"
}

output "tomcat_private_dns" {
  value = "${aws_instance.TomcatServer.*.private_dns}"
}
