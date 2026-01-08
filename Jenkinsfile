pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials ('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials ('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'us-east-2'
    }

    parameters {
    choice(
    name: 'TF_ACTION',
    choices: ['CREATE WEB AMI','CREATE PYTHON AMI','CREATE INFRASTRUCTURE','DEPLOY_PYTHON_APP', 'DEPLOY_WEB_APP','UPDATE DNS RECORD','OBTAIN SSL CERT','DESTROY INFRASTRUCTURE'],
    description: 'Select Action To Perform')
    }

    stages {  
        stage ('Create Web Server AMI') {
            when {
            expression {params.TF_ACTION == 'CREATE WEB AMI'}
            }
            steps {
                dir ('packer-ami') {
                 sh 'ls -ltr'
                 sh 'packer init .'
                 sh 'packer fmt .'
                 sh 'packer validate .'
                 sh 'packer build nginx-web.pkr.hcl'
                }
            }
        }

        stage ('Create Python Server AMI') {
            when {
            expression {params.TF_ACTION == 'CREATE PYTHON AMI'}
            }
            steps {
                dir ('packer-ami') {
                 sh 'ls -ltr'
                 sh 'packer init .'
                 sh 'packer fmt .'
                 sh 'packer validate .'
                 sh 'packer build python.pkr.hcl'
                }
            }
        }

        stage ('Create Infrastructure') { 
            when {
            expression {params.TF_ACTION == 'CREATE INFRASTRUCTURE'}
            }
            steps {
                dir ('terraform-infrastructure') {
                sh 'terraform init'
                sh 'terraform fmt'
                sh 'terraform validate'
                sh 'terraform plan -var-file="dev.tfvars"'
                sh 'terraform apply -var-file="dev.tfvars" --auto-approve'
                }
            }
        }

        stage ('Deploy Python App') {
            when {
            expression {params.TF_ACTION == 'DEPLOY PYTHON APP'}
            }
            steps {
                dir ('deployments') {
                 sshagent (credentials: ['AWS-SSH-KEY']) {
                sh '''
                PYTHON_INSTANCE_PRIVATE_IP=$(aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=python-instance" \
                --query "Reservations[].Instances[].PrivateIpAddress" \
                --output text)
                scp -o StrictHostKeyChecking=no $WORKSPACE/jenkins-files/deployments/fruits.service ubuntu@$PYTHON_INSTANCE_PRIVATE_IP:/tmp/fruits.service
                scp -o StrictHostKeyChecking=no $WORKSPACE/jenkins-files/deployments/python-deploy.sh ubuntu@$PYTHON_INSTANCE_PRIVATE_IP:/home/ubuntu/python-deploy.sh
                ssh -o StrictHostKeyChecking=no ubuntu@$PYTHON_INSTANCE_PRIVATE_IP << EOF
                sudo chmod +x python-deploy.sh
                ./python-deploy.sh
                '''
                 }
              }
            }
        }

        stage ('Deploy Nginx Web App') {     
            when {
            expression {params.TF_ACTION == 'DEPLOY_WEB_APP'}
            }
            steps {
                dir ('deployments') {
                 sshagent (credentials: ['AWS-SSH-KEY']) {
                sh '''
                WEB_INSTANCE_PRIVATE_IP=$(
                aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=web-instance" \
                --query 'Reservations[].Instances[].PrivateIpAddress | [0]' \
                --output text)
                scp -o StrictHostKeyChecking=no $WORKSPACE/jenkins-files/deployments/nginx-deploy.sh ubuntu@$WEB_INSTANCE_PRIVATE_IP:/home/ubuntu/nginx-deploy.sh
                ssh -o StrictHostKeyChecking=no ubuntu@$WEB_INSTANCE_PRIVATE_IP << 'EOF'
                sudo chmod +x nginx-deploy.sh
                ./nginx-deploy.sh
                '''
                 }
               }
            }
        }

        stage ('Update DNS A Record') {
            when {
            expression {params.TF_ACTION == 'UPDATE DNS RECORD'}
            }   
            steps {
                 sshagent (credentials: ['AWS-SSH-KEY']) {
                sh '''
                WEB_INSTANCE_PRIVATE_IP=$(
                aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=web-instance" \
                --query 'Reservations[].Instances[].PrivateIpAddress | [0]' \
                --output text)
                scp -o StrictHostKeyChecking=no $WORKSPACE/jenkins-files/deployments/namecheap-ddns.sh ubuntu@$WEB_INSTANCE_PRIVATE_IP:/home/ubuntu/namecheap-ddns.sh
                ssh -o StrictHostKeyChecking=no ubuntu@$WEB_INSTANCE_PRIVATE_IP << 'EOF'
                sudo chmod +x namecheap-ddns.sh
                ./namecheap-ddns.sh
                '''
                 }
            }
        }

        stage ('Obtain SSL Certificate') {    
            when {
            expression {params.TF_ACTION == 'OBTAIN SSL CERT'}
            }
            steps {
                 sshagent (credentials: ['AWS-SSH-KEY']) {
                sh '''
                WEB_INSTANCE_PRIVATE_IP=$(
                aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=web-instance" \
                --query 'Reservations[].Instances[].PrivateIpAddress | [0]' \
                --output text)
                scp -o StrictHostKeyChecking=no $WORKSPACE/jenkins-files/deployments/obtain_ssl_certificate.sh ubuntu@$WEB_INSTANCE_PRIVATE_IP:/home/ubuntu/obtain_ssl_certificate.sh
                ssh -o StrictHostKeyChecking=no ubuntu@$WEB_INSTANCE_PRIVATE_IP << 'EOF'
                sudo chmod +x obtain_ssl_certificate.sh
                ./obtain_ssl_certificate.sh
                '''
                 }
            }
        }

        stage ('Destroy Infrastructure') { 
        when {
            expression {params.TF_ACTION == 'DESTROY INFRASTRUCTURE'}
        }    
            steps {
                dir ('terraform-infrastructure') {
                sh 'terraform init'
                sh 'terraform fmt'
                sh 'terraform validate'
                sh 'terraform destroy --auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo 'Task completed successfully'
        }

        failure {
            echo 'Task failed'
        }
    }
}