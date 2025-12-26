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

#=========================================
#JAVA APP MACHINE VARIABLES
#=========================================
variable "java_machine_security_group_name" {
  type    = string
  default = "java-sg"
}

variable "java_machine_ingress_port" {
  type    = number
  default = 8080
}

variable "java_machine_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "java_machine_key_name" {
  type    = string
  default = "ohio-kp"

}

variable "java_machine_tag_name" {
  type    = string
  default = "java-instance"
}

#=========================================
#PYTHON APP MACHINE VARIABLES
#=========================================
variable "python_machine_security_group_name" {
  type    = string
  default = "python-sg"
}

variable "python_machine_ingress_port" {
  type    = number
  default = 9000
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

#=========================================
#WEB SERVER MACHINE VARIABLES
#=========================================
variable "web_machine_security_group_name" {
  type    = string
  default = "web-sg"
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

#=========================================
#DATABASE VARIABLES
#=========================================
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

variable "db_sg_ingress_from_port" {
  default = ""
}

variable "db_sg_ingress_to_port" {
  default = ""
}

 variable "db_instance_class" {
    default = ""
 } 