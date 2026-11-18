resource "google_compute_region_health_check" "producer" {
  name   = "psc-producer"
  region = "europe-west2"

  tcp_health_check {
    port = 443
  }

  log_config {
    enable = true
  }
}
