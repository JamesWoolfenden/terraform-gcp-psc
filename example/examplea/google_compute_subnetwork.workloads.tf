# Hosts the consumer endpoint address and the producer's internal load balancer.
resource "google_compute_subnetwork" "workloads" {
  name                     = "psc-workloads"
  ip_cidr_range            = "10.93.0.0/24"
  region                   = "europe-west2"
  network                  = google_compute_network.psc.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
