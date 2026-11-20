variable "name" {
  type        = string
  description = "Base name for the PSC addresses, forwarding rules, NAT subnet and service attachment"

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,48}[a-z0-9])?$", var.name))
    error_message = "var.name must be a lowercase RFC1035 name of at most 50 characters (suffixes are appended to it)"
  }
}

variable "region" {
  type        = string
  description = "Region for the consumer endpoint and the producer service attachment"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "network" {
  type        = string
  description = "Self link or ID of the VPC network the endpoints and the NAT subnet live in"

  validation {
    condition     = length(trimspace(var.network)) > 0
    error_message = "var.network must be a non-empty string"
  }
}

variable "consumer" {
  type = object({
    subnetwork          = string
    service_attachment  = string
    ip_address          = optional(string)
    allow_global_access = optional(bool, false)
  })
  description = "Consumer PSC endpoint (internal address + forwarding rule) to a producer's service attachment; null (the default) creates none. subnetwork: where the endpoint address is allocated; service_attachment: projects/P/regions/R/serviceAttachments/NAME or its self link; ip_address: optional static IP (GCP allocates one when null); allow_global_access: let clients in other regions reach the endpoint (off by default)"
  default     = null

  validation {
    condition     = var.consumer == null ? true : length(trimspace(var.consumer.subnetwork)) > 0
    error_message = "var.consumer.subnetwork must be a non-empty string"
  }

  validation {
    condition     = var.consumer == null ? true : can(regex("projects/[^/]+/regions/[^/]+/serviceAttachments/[^/]+$", var.consumer.service_attachment))
    error_message = "var.consumer.service_attachment must reference a service attachment (projects/P/regions/R/serviceAttachments/NAME)"
  }

  validation {
    condition     = var.consumer == null ? true : (var.consumer.ip_address == null ? true : can(cidrhost("${var.consumer.ip_address}/32", 0)))
    error_message = "var.consumer.ip_address must be a valid IPv4 address when set"
  }

  validation {
    condition     = var.consumer == null ? true : var.consumer.allow_global_access != null
    error_message = "var.consumer.allow_global_access must be true or false"
  }
}

variable "google_apis" {
  type = object({
    ip_address    = string
    bundle        = optional(string, "vpc-sc")
    endpoint_name = optional(string, "pscgoogleapis")
  })
  description = "Global PSC endpoint for a Google APIs bundle; null (the default) creates none. ip_address: internal IP that must not fall inside any subnet of var.network; bundle: vpc-sc (VPC Service Controls supported APIs only, the default) or all-apis; endpoint_name: 1-20 lowercase letters and digits, starting with a letter"
  default     = null

  validation {
    condition     = var.google_apis == null ? true : can(cidrhost("${var.google_apis.ip_address}/32", 0))
    error_message = "var.google_apis.ip_address must be a valid IPv4 address"
  }

  validation {
    condition     = var.google_apis == null ? true : contains(["vpc-sc", "all-apis"], coalesce(var.google_apis.bundle, "unset"))
    error_message = "var.google_apis.bundle must be one of vpc-sc or all-apis"
  }

  validation {
    condition     = var.google_apis == null ? true : can(regex("^[a-z][a-z0-9]{0,19}$", var.google_apis.endpoint_name))
    error_message = "var.google_apis.endpoint_name must be 1-20 lowercase letters or digits and start with a letter"
  }
}

variable "producer" {
  type = object({
    target_service = string
    nat_cidr       = string
    consumer_accept_list = list(object({
      project_id_or_num = optional(string)
      network_url       = optional(string)
      connection_limit  = number
    }))
    consumer_reject_list  = optional(list(string), [])
    enable_proxy_protocol = optional(bool, false)
    domain_names          = optional(list(string))
  })
  description = "Publish an internal load balancer through a service attachment with a dedicated PSC NAT subnet; null (the default) creates none. target_service: the load balancer's forwarding rule; nat_cidr: CIDR for the PSC NAT subnet (can only be widened in place to a range containing the current one; any other change replaces the subnet, which GCP refuses while the service attachment uses it, so remove and recreate the producer part instead); consumer_accept_list: consumers allowed to connect (ACCEPT_MANUAL), each naming one project or network and a connection limit; consumer_reject_list: projects/networks always rejected; enable_proxy_protocol: prepend the PROXY protocol header; domain_names: optional single DNS domain (ending in a dot) consumers get an automatic private zone for"
  default     = null

  validation {
    condition     = var.producer == null ? true : length(trimspace(var.producer.target_service)) > 0
    error_message = "var.producer.target_service must be a non-empty string"
  }

  validation {
    condition     = var.producer == null ? true : can(cidrhost(var.producer.nat_cidr, 0))
    error_message = "var.producer.nat_cidr must be a valid CIDR range"
  }

  validation {
    condition     = var.producer == null ? true : length(var.producer.consumer_accept_list) > 0
    error_message = "var.producer.consumer_accept_list must list at least one consumer"
  }

  validation {
    condition = var.producer == null ? true : alltrue([
      for c in var.producer.consumer_accept_list :
      (c.project_id_or_num == null) != (c.network_url == null) && c.connection_limit >= 1
    ])
    error_message = "Each var.producer.consumer_accept_list entry must set exactly one of project_id_or_num or network_url, and a connection_limit of at least 1"
  }

  validation {
    condition     = var.producer == null ? true : alltrue([for c in coalesce(var.producer.consumer_reject_list, []) : length(trimspace(c)) > 0])
    error_message = "var.producer.consumer_reject_list must not contain empty strings"
  }

  validation {
    condition     = var.producer == null ? true : var.producer.enable_proxy_protocol != null
    error_message = "var.producer.enable_proxy_protocol must be true or false"
  }

  validation {
    condition     = var.producer == null ? true : alltrue([for d in coalesce(var.producer.domain_names, []) : can(regex("\\.$", d))])
    error_message = "var.producer.domain_names entries must be fully qualified and end with a dot"
  }

  validation {
    condition     = var.producer == null ? true : length(coalesce(var.producer.domain_names, [])) <= 1
    error_message = "var.producer.domain_names supports at most one domain (a GCP service attachment limit)"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the PSC addresses and forwarding rules"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z0-9_-]{1,63}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase alphanumerics, underscores, or hyphens, 1-63 characters (GCP label constraints)"
  }
}
