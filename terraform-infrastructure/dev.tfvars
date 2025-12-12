
#=========================================
#GENERAL VARIABLES VALUES
#=========================================
region = "us-east-2"
   
security_group_cidr_block = "0.0.0.0/0"

#=========================================
#JAVA MACHINE VARIABLES VALUES
#=========================================
java_machine_security_group_name = "java-sg"

java_machine_ingress_port = 8080

java_machine_instance_type = "t3.micro"

java_machine_key_name = "ohio-kp"
   
java_machine_tag_name = "java-instance"

#=========================================
#PYTHON APP MACHINE VARIABLES
#=========================================
python_machine_security_group_name = "python-sg"
   
python_machine_ingress_port = 9000

python_machine_instance_type = "t3.micro"

python_machine_key_name = "ohio-kp"

python_machine_tag_name = "python-instance"

#=========================================
#WEB SERVER MACHINE VARIABLES
#=========================================
web_machine_security_group_name = "web-sg"

web_machine_instance_type = "t3.micro"

web_machine_key_name = "ohio-kp"

web_machine_tag_name = "web-instance"

