# terraform-gcp-psc

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-psc/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-psc/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-psc.svg)](https://github.com/JamesWoolfenden/terraform-gcp-psc/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-psc.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-psc/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.9.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Private Service Connect. Each part is toggled independently: a consumer endpoint (internal address plus forwarding rule) to a producer's service attachment, a global endpoint to the Google APIs bundle (`vpc-sc` by default, or `all-apis`), and a producer service attachment with a dedicated PSC NAT subnet that only accepts the consumers listed explicitly (`ACCEPT_MANUAL`).

## Usage

Add **module.psc.tf** to your code:-

```terraform
module "psc" {
  source  = "jameswoolfenden/psc/gcp"
  name    = "example-psc"
  region  = "europe-west2"
  network = google_compute_network.psc.id

  enable_consumer             = true
  consumer_subnetwork         = google_compute_subnetwork.workloads.id
  consumer_service_attachment = "projects/producer-project-id/regions/europe-west2/serviceAttachments/example-service"

  enable_google_apis     = true
  google_apis_bundle     = "vpc-sc"
  google_apis_ip_address = "10.255.255.254"

  enable_producer         = true
  producer_target_service = google_compute_forwarding_rule.producer.id
  producer_nat_cidr       = "10.94.0.0/24"
  producer_consumer_accept_list = [
    { project_id_or_num = "consumer-project-id", connection_limit = 10 },
  ]
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
| <a name="input_consumer_allow_global_access"></a> [consumer\_allow\_global\_access](#input\_consumer\_allow\_global\_access) | Allow clients in other regions to reach the consumer endpoint; off by default to keep access regional | `bool` | `false` | no |
| <a name="input_consumer_ip_address"></a> [consumer\_ip\_address](#input\_consumer\_ip\_address) | Optional static internal IP for the consumer endpoint; GCP allocates one from var.consumer\_subnetwork when null | `string` | `null` | no |
| <a name="input_consumer_service_attachment"></a> [consumer\_service\_attachment](#input\_consumer\_service\_attachment) | Service attachment the consumer endpoint connects to, as projects/P/regions/R/serviceAttachments/NAME or its self link (required when var.enable\_consumer is true) | `string` | `null` | no |
| <a name="input_consumer_subnetwork"></a> [consumer\_subnetwork](#input\_consumer\_subnetwork) | Subnetwork the consumer endpoint's internal address is allocated from (required when var.enable\_consumer is true) | `string` | `null` | no |
| <a name="input_enable_consumer"></a> [enable\_consumer](#input\_enable\_consumer) | Create a consumer PSC endpoint (internal address + forwarding rule) to var.consumer\_service\_attachment | `bool` | `false` | no |
| <a name="input_enable_google_apis"></a> [enable\_google\_apis](#input\_enable\_google\_apis) | Create a global PSC endpoint for the Google APIs bundle in var.google\_apis\_bundle | `bool` | `false` | no |
| <a name="input_enable_producer"></a> [enable\_producer](#input\_enable\_producer) | Publish var.producer\_target\_service through a service attachment with a dedicated PSC NAT subnet | `bool` | `false` | no |
| <a name="input_google_apis_bundle"></a> [google\_apis\_bundle](#input\_google\_apis\_bundle) | Google APIs bundle the endpoint targets: vpc-sc (VPC Service Controls supported APIs only) or all-apis | `string` | `"vpc-sc"` | no |
| <a name="input_google_apis_endpoint_name"></a> [google\_apis\_endpoint\_name](#input\_google\_apis\_endpoint\_name) | Name of the Google APIs PSC endpoint; GCP requires 1-20 lowercase letters and digits, starting with a letter | `string` | `"pscgoogleapis"` | no |
| <a name="input_google_apis_ip_address"></a> [google\_apis\_ip\_address](#input\_google\_apis\_ip\_address) | Internal IP for the Google APIs endpoint; must not fall inside any subnet of var.network (required when var.enable\_google\_apis is true) | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the PSC addresses and forwarding rules | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the PSC addresses, forwarding rules, NAT subnet and service attachment | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Self link or ID of the VPC network the endpoints and the NAT subnet live in | `string` | n/a | yes |
| <a name="input_producer_consumer_accept_list"></a> [producer\_consumer\_accept\_list](#input\_producer\_consumer\_accept\_list) | Consumers allowed to connect (ACCEPT\_MANUAL): each entry names a project or a network and a connection limit | <pre>list(object({<br/>    project_id_or_num = optional(string)<br/>    network_url       = optional(string)<br/>    connection_limit  = number<br/>  }))</pre> | `[]` | no |
| <a name="input_producer_consumer_reject_list"></a> [producer\_consumer\_reject\_list](#input\_producer\_consumer\_reject\_list) | Consumer project IDs/numbers or network URLs that are always rejected | `list(string)` | `[]` | no |
| <a name="input_producer_domain_names"></a> [producer\_domain\_names](#input\_producer\_domain\_names) | Optional DNS domain (ending in a dot) consumers get an automatic private zone for | `list(string)` | `null` | no |
| <a name="input_producer_enable_proxy_protocol"></a> [producer\_enable\_proxy\_protocol](#input\_producer\_enable\_proxy\_protocol) | Prepend the PROXY protocol header so the producer can see the consumer's connection details | `bool` | `false` | no |
| <a name="input_producer_nat_cidr"></a> [producer\_nat\_cidr](#input\_producer\_nat\_cidr) | CIDR range for the PSC NAT subnet (required when var.enable\_producer is true) | `string` | `null` | no |
| <a name="input_producer_target_service"></a> [producer\_target\_service](#input\_producer\_target\_service) | Forwarding rule of the internal load balancer to publish (required when var.enable\_producer is true) | `string` | `null` | no |
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
