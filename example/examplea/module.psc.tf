# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "psc" {
  source  = "../../"
  name    = "example-psc"
  region  = "europe-west2"
  network = google_compute_network.psc.id

  consumer = {
    subnetwork         = google_compute_subnetwork.workloads.id
    service_attachment = var.consumer_service_attachment
  }

  google_apis = {
    ip_address = "10.255.255.254"
    bundle     = "vpc-sc"
  }

  producer = {
    target_service = google_compute_forwarding_rule.producer.id
    nat_cidr       = "10.94.0.0/24"
    consumer_accept_list = [
      {
        project_id_or_num = data.google_project.current.project_id
        connection_limit  = 10
      },
    ]
  }

  labels = {
    environment = "example"
  }
}
