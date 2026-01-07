pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials ('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials ('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'us-east-2'
    }

    stages {  
        

        stage ('Create Infrastructure') { 
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
            expression {params.TF_ACTION == 'DESTROY'}
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
            echo 'Task successfully'
        }

        failure {
            echo 'Task failed'
        }
    }
}