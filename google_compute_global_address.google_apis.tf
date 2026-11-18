# Internal IP for the Private Service Connect endpoint to Google APIs.
resource "google_compute_global_address" "google_apis" {
  count = local.google_apis_count

  name         = "${var.name}-google-apis"
  description  = "Private Service Connect address for Google APIs (${var.google_apis.bundle})"
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = var.network
  address      = var.google_apis.ip_address
  labels       = var.labels

  # Clients and DNS records point at this IP; replacing it silently breaks them.
  lifecycle {
    prevent_destroy = true
  }
}
