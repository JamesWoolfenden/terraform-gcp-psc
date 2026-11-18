# PSC endpoint: a forwarding rule with an empty load balancing scheme whose
# target is the producer's service attachment.
resource "google_compute_forwarding_rule" "consumer" {
  count = local.consumer_count

  name                    = "${var.name}-consumer"
  region                  = var.region
  description             = "Private Service Connect endpoint for ${var.name}"
  network                 = var.network
  ip_address              = google_compute_address.consumer[0].id
  target                  = var.consumer.service_attachment
  load_balancing_scheme   = ""
  allow_psc_global_access = var.consumer.allow_global_access
  labels                  = var.labels
}
