# Output values

output "bastion_linux-private_ip" {
  description = "Private IP of bastion_linux"
  value       = aws_instance.bastion_linux.private_ip
}

output "bastion_linux-private_dns" {
  description = "Private DNS of bastion_linux"
  value       = aws_instance.bastion_linux.private_dns
}

output "bastion_windows-private_ip" {
  description = "Private IP of bastion_windows"
  value       = aws_instance.bastion_windows.private_ip
}

output "bastion_windows-private_dns" {
  description = "Private DNS of bastion_windows"
  value       = aws_instance.bastion_windows.private_dns
}

output "app-private_ip" {
  description = "Private IP of app"
  value       = { for k, v in aws_instance.app : k => v.private_ip }
}

output "app-private_dns" {
  description = "Private DNS of app"
  value       = { for k, v in aws_instance.app : k => v.private_dns }
}

output "mongodb-private_ip" {
  description = "Private IP of mongodb"
  value       = { for k, v in aws_instance.mongodb : k => v.private_ip }
}

output "mongodb-private_dns" {
  description = "Private DNS of mongodb"
  value       = { for k, v in aws_instance.mongodb : k => v.private_dns }
}

output "elasticsearch-private_ip" {
  description = "Private IP of elasticsearch"
  value       = { for k, v in aws_instance.elasticsearch : k => v.private_ip }
}

output "elasticsearch-private_dns" {
  description = "Private DNS of elasticsearch"
  value       = { for k, v in aws_instance.elasticsearch : k => v.private_dns }
}

output "opsmanager-private_ip" {
  description = "Private IP of opsmanager"
  value       = aws_instance.opsmanager.private_ip
}

output "opsmanager-private_dns" {
  description = "Private DNS of opsmanager"
  value       = aws_instance.opsmanager.private_dns
}

output "stresstest-private_ip" {
  description = "Private IP of stresstest"
  value       = aws_instance.stresstest.private_ip
}

output "stresstest-private_dns" {
  description = "Private DNS of stresstest"
  value       = aws_instance.stresstest.private_dns
}

output "web-private_ip" {
  description = "Private IP of web"
  value       = { for k, v in aws_instance.web : k => v.private_ip }
}

output "web-private_dns" {
  description = "Private DNS of web"
  value       = { for k, v in aws_instance.web : k => v.private_dns }
}

