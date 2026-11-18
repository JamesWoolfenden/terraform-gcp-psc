# Backends are attached by the service owner; the example only needs a
# published internal load balancer for the service attachment to point at.
resource "google_compute_region_backend_service" "producer" {
  name                            = "psc-producer"
  region                          = "europe-west2"
  protocol                        = "TCP"
  load_balancing_scheme           = "INTERNAL"
  health_checks                   = [google_compute_region_health_check.producer.id]
  connection_draining_timeout_sec = 300

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}
