
#=========================================
#GENERAL VARIABLES VALUES
#=========================================
region = "us-east-2"

security_group_cidr_block = "0.0.0.0/0"

#=========================================
#PYTHON APP MACHINE VARIABLES
#=========================================
python_machine_security_group_name = "python-sg"

python_machine_ingress_port = 9000

python_machine_instance_type = "t3.micro"

python_machine_key_name = "ohio-kp"

python_machine_tag_name = "python-instance"

#=========================================
#WEB SERVER MACHINE VARIABLES VALUES
#=========================================
web_machine_security_group_name = "web-sg"

web_machine_instance_type = "t3.micro"

web_machine_key_name = "ohio-kp"

web_machine_tag_name = "web-instance"

#=========================================
#POSTGRES DATABASE VARIABLES VALUES
#=========================================
db_identifier = "my_postgres_db"

db_engine = "postgres"

engine_version = "15.3"

db_instance_class = "db.t4g.micro"

db_name = "mydb"

db_username = "username"

db_password = "password"

db_environment = "dev"


#=================================================
#POSTGRES DATABASE SECURITY GROUP VARIABLES VALUES
#=================================================
db_sg_name = "postgres-sg"

db_sg_ingress_from_port = 5432

db_sg_ingress_to_port = 5432