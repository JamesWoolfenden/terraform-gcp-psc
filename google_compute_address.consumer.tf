# Internal IP the consumer endpoint is reachable on inside var.network.
resource "google_compute_address" "consumer" {
  count = local.consumer_count

  name         = "${var.name}-consumer"
  region       = var.region
  description  = "Private Service Connect endpoint address for ${var.name}"
  address_type = "INTERNAL"
  subnetwork   = var.consumer.subnetwork
  address      = var.consumer.ip_address
  labels       = var.labels

  # Clients and DNS records point at this IP; replacing it silently breaks them.
  lifecycle {
    prevent_destroy = true
  }
}
