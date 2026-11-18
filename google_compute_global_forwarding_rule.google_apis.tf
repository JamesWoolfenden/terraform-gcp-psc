# PSC endpoint for the Google APIs bundle. "vpc-sc" restricts the endpoint to
# APIs that support VPC Service Controls; "all-apis" exposes every Google API.
resource "google_compute_global_forwarding_rule" "google_apis" {
  count = local.google_apis_count

  name                  = var.google_apis.endpoint_name
  description           = "Private Service Connect endpoint for Google APIs (${var.google_apis.bundle})"
  network               = var.network
  ip_address            = google_compute_global_address.google_apis[0].id
  target                = var.google_apis.bundle
  load_balancing_scheme = ""
  labels                = var.labels
}
