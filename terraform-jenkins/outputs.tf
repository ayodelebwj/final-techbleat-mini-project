#======================================================
#OUTPUTS 
#======================================================
output "vpc-id" {
  description = "vpc id"
  value       = aws_vpc.techbleatvpc.id
}

output "jenkins_instance_public_ip" {
  description = "public ip for the jenkins instance"
  value       = aws_instance.jenkins_instance.public_ip
}