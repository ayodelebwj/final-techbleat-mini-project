 
 
 
 
 
 #!/bin/bash
#=========================================================================
# INSTALL GIT
#=========================================================================
sudo apt update && sudo apt upgrade -y
sudo apt install git -y
git --version
#=========================================================================
# INSTALL PACKER AND TERRAFORM
#=========================================================================
# Install prerequisites
sudo apt update
sudo apt install -y curl gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform packer -y
#=========================================================================
# INSTALL JENKINS
#=========================================================================
# Install Java
sudo apt install -y openjdk-17-jdk

# Add Jenkins GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

#=========================================================================
# Add Jenkins repo with signed-by reference
#=========================================================================
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Enable and start service
sudo systemctl enable jenkins
sudo systemctl start jenkins
 
 
 # Install AWS CLI and Unzip
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install