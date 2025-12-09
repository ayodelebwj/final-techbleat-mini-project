#============================================
#Provision Web AMI Templates
#============================================

data "amazon-parameterstore" "web_ubuntu_params" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

source "amazon-ebs" "web-vm-source" {
  region          = "us-east-2"
  instance_type   = "t3.micro"
  ssh_username    = "ubuntu"
  source_ami      = data.amazon-parameterstore.web_ubuntu_params.value
  ami_name        = "web-ami"
}

build {
  name    = "web-build"
  sources = ["source.amazon-ebs.web-vm-source"]

  provisioner "shell" {
    inline_shebang = "/bin/bash -xe"
    inline = [
      "sudo apt update -y",
      "sudo apt install awscli -y"
    ]
  }
}
