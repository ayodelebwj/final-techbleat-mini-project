#============================================
#Provision Web AMI Template
#============================================


#================================================================
#RETRIEVES UBUNTU AMI FROM AWS STORE TO PROVISION AMI TEMPLATE VM
#================================================================
data "amazon-parameterstore" "web_ubuntu_params" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}


#================================================================
#CREATES THE INSTANCE NEEDED TO BUILD AMI AND CREATE A TEMPLATE
#================================================================
source "amazon-ebs" "web-vm-source" {
  region        = "us-east-2"
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"
  source_ami    = data.amazon-parameterstore.web_ubuntu_params.value
  ami_name      = "web-ami"
}

#================================================================
#BUILDS THE NGINX WEB SERVER AMI TEMPLATE
#================================================================
build {
  name    = "web-build"
  sources = ["source.amazon-ebs.web-vm-source"]

  provisioner "shell" {
    inline_shebang = "/bin/bash -xe"
    inline = [
      "sudo apt update -y",
      "sudo apt install certbot python3-certbot-nginx -y",
      "sudo apt install unzip -y",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install"
    ]
  }
}
