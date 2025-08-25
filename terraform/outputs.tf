output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_url" {
  description = "Access Jenkins at"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}
