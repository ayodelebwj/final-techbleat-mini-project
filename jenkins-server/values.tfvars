region = "us-east-2"

security_group_name = "jenkins-sg"
   
security_group_ingress_ssh_port = 22

security_group_ingress_jenkins_port = 8080

security_group_cidr_block = "0.0.0.0/0"

jenkins_server_instance_type = "c7i-flex.large"

jenkins_server_key_name = "ohio-kp"
    
jenkins_server_tag_name = "jenkins-instance"
   