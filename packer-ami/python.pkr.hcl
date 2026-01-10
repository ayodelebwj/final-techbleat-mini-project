#============================================
#Provision Java AMI Template
#============================================

#================================================================
#RETRIEVES UBUNTU AMI FROM AWS STORE TO PROVISION AMI TEMPLATE VM
#================================================================
#Retrieves ubuntu ami from aws store to provision instance source
data "amazon-parameterstore" "python_ubuntu_params" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

#================================================================
#CREATES THE INSTANCE NEEDED TO BUILD AMI AND CREATE A TEMPLATE
#================================================================
#Creates the instance to build AMI off it
source "amazon-ebs" "python-vm-source" {
  region        = "us-east-1"
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  source_ami    = data.amazon-parameterstore.python_ubuntu_params.value
  ami_name      = "python-ami"
}


#================================================================
#BUILDS THE PYTHON SERVER AMI TEMPLATE
#================================================================
build {
  name    = "python-build"
  sources = ["source.amazon-ebs.python-vm-source"]

  provisioner "shell" {
    inline_shebang = "/bin/bash -xe"
    inline = [
      "sudo apt update -y",
      "sudo apt install python3 python3-pip python3-venv -y",
      "sudo apt install unzip -y",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "exit 0"
    ]
  }
}
