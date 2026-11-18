# terraform-gcp-psc

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-psc/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-psc/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-psc.svg)](https://github.com/JamesWoolfenden/terraform-gcp-psc/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-psc.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-psc/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Private Service Connect. Each part is enabled independently by passing its object (`consumer`, `google_apis`, `producer`; null skips it): a consumer endpoint (internal address plus forwarding rule) to a producer's service attachment, a global endpoint to the Google APIs bundle (`vpc-sc` by default, or `all-apis`), and a producer service attachment with a dedicated PSC NAT subnet that only accepts the consumers listed explicitly (`ACCEPT_MANUAL`).

## Usage

Add **module.psc.tf** to your code:-

```terraform
module "psc" {
  source  = "jameswoolfenden/psc/gcp"
  name    = "example-psc"
  region  = "europe-west2"
  network = google_compute_network.psc.id

  consumer = {
    subnetwork         = google_compute_subnetwork.workloads.id
    service_attachment = "projects/producer-project-id/regions/europe-west2/serviceAttachments/example-service"
  }

  google_apis = {
    ip_address = "10.255.255.254"
    bundle     = "vpc-sc"
  }

  producer = {
    target_service = google_compute_forwarding_rule.producer.id
    nat_cidr       = "10.94.0.0/24"
    consumer_accept_list = [
      { project_id_or_num = "consumer-project-id", connection_limit = 10 },
    ]
  }
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_address.consumer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.consumer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_service_attachment.producer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [google_compute_subnetwork.psc_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_consumer"></a> [consumer](#input\_consumer) | Consumer PSC endpoint (internal address + forwarding rule) to a producer's service attachment; null (the default) creates none. subnetwork: where the endpoint address is allocated; service\_attachment: projects/P/regions/R/serviceAttachments/NAME or its self link; ip\_address: optional static IP (GCP allocates one when null); allow\_global\_access: let clients in other regions reach the endpoint (off by default) | <pre>object({<br/>    subnetwork          = string<br/>    service_attachment  = string<br/>    ip_address          = optional(string)<br/>    allow_global_access = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_google_apis"></a> [google\_apis](#input\_google\_apis) | Global PSC endpoint for a Google APIs bundle; null (the default) creates none. ip\_address: internal IP that must not fall inside any subnet of var.network; bundle: vpc-sc (VPC Service Controls supported APIs only, the default) or all-apis; endpoint\_name: 1-20 lowercase letters and digits, starting with a letter | <pre>object({<br/>    ip_address    = string<br/>    bundle        = optional(string, "vpc-sc")<br/>    endpoint_name = optional(string, "pscgoogleapis")<br/>  })</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the PSC addresses and forwarding rules | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the PSC addresses, forwarding rules, NAT subnet and service attachment | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Self link or ID of the VPC network the endpoints and the NAT subnet live in | `string` | n/a | yes |
| <a name="input_producer"></a> [producer](#input\_producer) | Publish an internal load balancer through a service attachment with a dedicated PSC NAT subnet; null (the default) creates none. target\_service: the load balancer's forwarding rule; nat\_cidr: CIDR for the PSC NAT subnet; consumer\_accept\_list: consumers allowed to connect (ACCEPT\_MANUAL), each naming one project or network and a connection limit; consumer\_reject\_list: projects/networks always rejected; enable\_proxy\_protocol: prepend the PROXY protocol header; domain\_names: optional single DNS domain (ending in a dot) consumers get an automatic private zone for | <pre>object({<br/>    target_service = string<br/>    nat_cidr       = string<br/>    consumer_accept_list = list(object({<br/>      project_id_or_num = optional(string)<br/>      network_url       = optional(string)<br/>      connection_limit  = number<br/>    }))<br/>    consumer_reject_list  = optional(list(string), [])<br/>    enable_proxy_protocol = optional(bool, false)<br/>    domain_names          = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the consumer endpoint and the producer service attachment | `string` | `"europe-west2"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_consumer_forwarding_rule_id"></a> [consumer\_forwarding\_rule\_id](#output\_consumer\_forwarding\_rule\_id) | ID of the consumer PSC forwarding rule (null when the consumer part is disabled) |
| <a name="output_consumer_ip_address"></a> [consumer\_ip\_address](#output\_consumer\_ip\_address) | Internal IP address of the consumer PSC endpoint (null when the consumer part is disabled) |
| <a name="output_consumer_psc_connection_status"></a> [consumer\_psc\_connection\_status](#output\_consumer\_psc\_connection\_status) | Connection status of the consumer PSC endpoint, e.g. ACCEPTED or PENDING (null when disabled) |
| <a name="output_google_apis_forwarding_rule_id"></a> [google\_apis\_forwarding\_rule\_id](#output\_google\_apis\_forwarding\_rule\_id) | ID of the Google APIs PSC forwarding rule (null when the Google APIs part is disabled) |
| <a name="output_google_apis_ip_address"></a> [google\_apis\_ip\_address](#output\_google\_apis\_ip\_address) | Internal IP address of the Google APIs PSC endpoint (null when the Google APIs part is disabled) |
| <a name="output_psc_nat_subnetwork_id"></a> [psc\_nat\_subnetwork\_id](#output\_psc\_nat\_subnetwork\_id) | ID of the producer PSC NAT subnet (null when the producer part is disabled) |
| <a name="output_service_attachment_id"></a> [service\_attachment\_id](#output\_service\_attachment\_id) | ID of the producer service attachment, to hand to consumers (null when the producer part is disabled) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "compute.addresses.create",
    "compute.addresses.createInternal",
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.addresses.get",
    "compute.addresses.setLabels",
    "compute.forwardingRules.create",
    "compute.forwardingRules.delete",
    "compute.forwardingRules.get",
    "compute.forwardingRules.setLabels",
    "compute.forwardingRules.update",
    "compute.globalAddresses.create",
    "compute.globalAddresses.createInternal",
    "compute.globalAddresses.delete",
    "compute.globalAddresses.deleteInternal",
    "compute.globalAddresses.get",
    "compute.globalAddresses.setLabels",
    "compute.globalForwardingRules.create",
    "compute.globalForwardingRules.delete",
    "compute.globalForwardingRules.get",
    "compute.globalForwardingRules.update",
    "compute.networks.updatePolicy",
    "compute.networks.use",
    "compute.serviceAttachments.create",
    "compute.serviceAttachments.delete",
    "compute.serviceAttachments.get",
    "compute.serviceAttachments.update",
    "compute.subnetworks.create",
    "compute.subnetworks.delete",
    "compute.subnetworks.get",
    "compute.subnetworks.update",
    "compute.subnetworks.use"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "compute.addresses.get",
    "compute.forwardingRules.get",
    "compute.globalAddresses.get",
    "compute.globalForwardingRules.get",
    "compute.serviceAttachments.get",
    "compute.subnetworks.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-psc/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-psc/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
