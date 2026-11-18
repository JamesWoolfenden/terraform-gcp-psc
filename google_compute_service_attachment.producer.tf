# Publishes var.producer_target_service. Connections are accepted only from
# the projects/networks in var.producer_consumer_accept_list (ACCEPT_MANUAL).
resource "google_compute_service_attachment" "producer" {
  count = local.producer_count

  name                  = "${var.name}-producer"
  region                = var.region
  description           = "Private Service Connect service attachment for ${var.name}"
  target_service        = var.producer_target_service
  nat_subnets           = [google_compute_subnetwork.psc_nat[0].id]
  connection_preference = "ACCEPT_MANUAL"
  enable_proxy_protocol = var.producer_enable_proxy_protocol
  consumer_reject_lists = var.producer_consumer_reject_list
  domain_names          = var.producer_domain_names
  reconcile_connections = true

  dynamic "consumer_accept_lists" {
    for_each = var.producer_consumer_accept_list
    content {
      project_id_or_num = consumer_accept_lists.value.project_id_or_num
      network_url       = consumer_accept_lists.value.network_url
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }
}
