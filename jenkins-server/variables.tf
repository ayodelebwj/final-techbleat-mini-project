variable "region" {
    type = string
    default = "us-east-2"
}


variable "security_group_name" {
    type = string
    default = "jenkins-sg"
}



variable "security_group_ingress_ssh_port" {
    type = number
    default = 22
}

variable "security_group_ingress_jenkins_port" {
    type = number
    default = 8080
}

variable "security_group_cidr_block" {
    type = string
    default = "0.0.0.0/0"
}

variable "jenkins_server_instance_type" {
    type = string
    default = "c7i-flex.large"
}

variable "jenkins_server_key_name" {
    type = string
}

variable "jenkins_server_tag_name" {
    type = string
    default = "jenkins-instance"
}