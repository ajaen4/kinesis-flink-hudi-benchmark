output "load_balancer_dns" {
  description = "The DNS name of the Load Balancer created by the Locust Helm chart"
  value       = "${module.eks.load_balancer_dns}:8089"
}
