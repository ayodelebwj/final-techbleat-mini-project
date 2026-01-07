#=========================================
#GENERAL VARIABLES
#=========================================
variable "region" {
  type    = string
  default = "us-east-2"
}

variable "security_group_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "python_machine_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "python_machine_key_name" {
  type    = string
  default = "ohio-kp"

}

variable "python_machine_tag_name" {
  type    = string
  default = "python-instance"
}

variable "web_machine_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "web_machine_key_name" {
  type    = string
  default = "ohio-kp"
}

variable "web_machine_tag_name" {
  type    = string
  default = "web-instance"
}

variable "db_identifier" {
  default = ""
}

variable "db_engine" {
  default = ""
}

variable "db_engine_version" {
  default = ""
}

variable "db_engine_class" {
  default = ""
}

variable "db_name" {
  default = ""
}

variable "db_username" {
  default = ""
}

variable "db_password" {
  default = ""
}

variable "db_environment" {
  default = ""
}

variable "db_sg_name" {
  default = ""
}

 variable "db_instance_class" {
    default = ""
 } 