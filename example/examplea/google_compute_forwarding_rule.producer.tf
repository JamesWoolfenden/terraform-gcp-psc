resource "google_compute_forwarding_rule" "producer" {
  name                  = "psc-producer"
  region                = "europe-west2"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.producer.id
  network               = google_compute_network.psc.id
  subnetwork            = google_compute_subnetwork.workloads.id
  ip_protocol           = "TCP"
  ports                 = ["443"]
}
