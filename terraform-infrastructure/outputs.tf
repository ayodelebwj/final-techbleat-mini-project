

#======================================================
#OUTPUTS PYTHON PUBLIC IP ADDRESS
#======================================================
output "python_instance_public_ip" {
  description = "public ip for the python instance"
  value       = aws_instance.python_instance.public_ip
}

#======================================================
#OUTPUTS WEB PUBLIC IP ADDRESS
#======================================================
output "web_instance_public_ip" {
  description = "public ip for the jenkins instance"
  value       = aws_instance.web_instance.public_ip
}