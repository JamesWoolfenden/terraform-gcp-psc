output "consumer_ip_address" {
  value       = one(google_compute_address.consumer[*].address)
  description = "Internal IP address of the consumer PSC endpoint (null when the consumer part is disabled)"
}

output "consumer_forwarding_rule_id" {
  value       = one(google_compute_forwarding_rule.consumer[*].id)
  description = "ID of the consumer PSC forwarding rule (null when the consumer part is disabled)"
}

output "consumer_psc_connection_status" {
  value       = one(google_compute_forwarding_rule.consumer[*].psc_connection_status)
  description = "Connection status of the consumer PSC endpoint, e.g. ACCEPTED or PENDING (null when disabled)"
}

output "google_apis_ip_address" {
  value       = one(google_compute_global_address.google_apis[*].address)
  description = "Internal IP address of the Google APIs PSC endpoint (null when the Google APIs part is disabled)"
}

output "google_apis_forwarding_rule_id" {
  value       = one(google_compute_global_forwarding_rule.google_apis[*].id)
  description = "ID of the Google APIs PSC forwarding rule (null when the Google APIs part is disabled)"
}

output "service_attachment_id" {
  value       = one(google_compute_service_attachment.producer[*].id)
  description = "ID of the producer service attachment, to hand to consumers (null when the producer part is disabled)"
}

output "psc_nat_subnetwork_id" {
  value       = one(google_compute_subnetwork.psc_nat[*].id)
  description = "ID of the producer PSC NAT subnet (null when the producer part is disabled)"
}
