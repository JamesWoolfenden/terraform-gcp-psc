# Dedicated NAT subnet the service attachment translates consumer traffic
# into; PRIVATE_SERVICE_CONNECT subnets cannot host VMs.
resource "google_compute_subnetwork" "psc_nat" {
  count = local.producer_count

  name          = "${var.name}-psc-nat"
  region        = var.region
  description   = "Private Service Connect NAT subnet for ${var.name}"
  network       = var.network
  ip_cidr_range = var.producer.nat_cidr
  purpose       = "PRIVATE_SERVICE_CONNECT"
}
