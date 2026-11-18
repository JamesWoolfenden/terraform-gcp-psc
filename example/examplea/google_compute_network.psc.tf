# holden:ignore:HLD_GCP_093: Just enough to drive the module
# holden:ignore:HLD_GCP_303 — Google API traffic leaves through module.psc's
# private Google APIs endpoint; nothing in this example needs internet egress.
resource "google_compute_network" "psc" {
  name                            = "psc-example"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}
