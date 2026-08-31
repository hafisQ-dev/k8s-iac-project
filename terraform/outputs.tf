output "master_public_ip" {
  description = "Kubernetes Master Node Public IP Adresi"
  value       = aws_instance.k8s_master.public_ip
}

output "worker_public_ips" {
  description = "Kubernetes Worker Node Public IP Adresleri"
  value       = aws_instance.k8s_worker[*].public_ip
}
