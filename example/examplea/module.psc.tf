# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "psc" {
  source  = "../../"
  name    = "example-psc"
  region  = "europe-west2"
  network = google_compute_network.psc.id

  enable_consumer             = true
  consumer_subnetwork         = google_compute_subnetwork.workloads.id
  consumer_service_attachment = var.consumer_service_attachment

  enable_google_apis     = true
  google_apis_bundle     = "vpc-sc"
  google_apis_ip_address = "10.255.255.254"

  enable_producer         = true
  producer_target_service = google_compute_forwarding_rule.producer.id
  producer_nat_cidr       = "10.94.0.0/24"
  producer_consumer_accept_list = [
    {
      project_id_or_num = data.google_project.current.project_id
      connection_limit  = 10
    },
  ]

  labels = {
    environment = "example"
  }
}
