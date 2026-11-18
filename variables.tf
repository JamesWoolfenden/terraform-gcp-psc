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

variable "enable_consumer" {
  type        = bool
  description = "Create a consumer PSC endpoint (internal address + forwarding rule) to var.consumer_service_attachment"
  default     = false

  validation {
    condition     = var.enable_consumer != null
    error_message = "var.enable_consumer must be true or false"
  }
}

variable "consumer_subnetwork" {
  type        = string
  description = "Subnetwork the consumer endpoint's internal address is allocated from (required when var.enable_consumer is true)"
  default     = null

  validation {
    condition     = var.consumer_subnetwork == null || length(trimspace(coalesce(var.consumer_subnetwork, " "))) > 0
    error_message = "var.consumer_subnetwork must not be an empty string when set"
  }

  validation {
    condition     = !var.enable_consumer || var.consumer_subnetwork != null
    error_message = "var.consumer_subnetwork is required when var.enable_consumer is true"
  }
}

variable "consumer_ip_address" {
  type        = string
  description = "Optional static internal IP for the consumer endpoint; GCP allocates one from var.consumer_subnetwork when null"
  default     = null

  validation {
    condition     = var.consumer_ip_address == null || can(cidrhost("${coalesce(var.consumer_ip_address, "0.0.0.0")}/32", 0))
    error_message = "var.consumer_ip_address must be a valid IPv4 address when set"
  }
}

variable "consumer_service_attachment" {
  type        = string
  description = "Service attachment the consumer endpoint connects to, as projects/P/regions/R/serviceAttachments/NAME or its self link (required when var.enable_consumer is true)"
  default     = null

  validation {
    condition     = var.consumer_service_attachment == null || can(regex("projects/[^/]+/regions/[^/]+/serviceAttachments/[^/]+$", coalesce(var.consumer_service_attachment, " ")))
    error_message = "var.consumer_service_attachment must reference a service attachment (projects/P/regions/R/serviceAttachments/NAME)"
  }

  validation {
    condition     = !var.enable_consumer || var.consumer_service_attachment != null
    error_message = "var.consumer_service_attachment is required when var.enable_consumer is true"
  }
}

variable "consumer_allow_global_access" {
  type        = bool
  description = "Allow clients in other regions to reach the consumer endpoint; off by default to keep access regional"
  default     = false

  validation {
    condition     = var.consumer_allow_global_access != null
    error_message = "var.consumer_allow_global_access must be true or false"
  }
}

variable "enable_google_apis" {
  type        = bool
  description = "Create a global PSC endpoint for the Google APIs bundle in var.google_apis_bundle"
  default     = false

  validation {
    condition     = var.enable_google_apis != null
    error_message = "var.enable_google_apis must be true or false"
  }
}

variable "google_apis_bundle" {
  type        = string
  description = "Google APIs bundle the endpoint targets: vpc-sc (VPC Service Controls supported APIs only) or all-apis"
  default     = "vpc-sc"

  validation {
    condition     = contains(["vpc-sc", "all-apis"], var.google_apis_bundle)
    error_message = "var.google_apis_bundle must be one of vpc-sc or all-apis"
  }
}

variable "google_apis_endpoint_name" {
  type        = string
  description = "Name of the Google APIs PSC endpoint; GCP requires 1-20 lowercase letters and digits, starting with a letter"
  default     = "pscgoogleapis"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,19}$", var.google_apis_endpoint_name))
    error_message = "var.google_apis_endpoint_name must be 1-20 lowercase letters or digits and start with a letter"
  }
}

variable "google_apis_ip_address" {
  type        = string
  description = "Internal IP for the Google APIs endpoint; must not fall inside any subnet of var.network (required when var.enable_google_apis is true)"
  default     = null

  validation {
    condition     = var.google_apis_ip_address == null || can(cidrhost("${coalesce(var.google_apis_ip_address, "0.0.0.0")}/32", 0))
    error_message = "var.google_apis_ip_address must be a valid IPv4 address when set"
  }

  validation {
    condition     = !var.enable_google_apis || var.google_apis_ip_address != null
    error_message = "var.google_apis_ip_address is required when var.enable_google_apis is true"
  }
}

variable "enable_producer" {
  type        = bool
  description = "Publish var.producer_target_service through a service attachment with a dedicated PSC NAT subnet"
  default     = false

  validation {
    condition     = var.enable_producer != null
    error_message = "var.enable_producer must be true or false"
  }
}

variable "producer_target_service" {
  type        = string
  description = "Forwarding rule of the internal load balancer to publish (required when var.enable_producer is true)"
  default     = null

  validation {
    condition     = var.producer_target_service == null || length(trimspace(coalesce(var.producer_target_service, " "))) > 0
    error_message = "var.producer_target_service must not be an empty string when set"
  }

  validation {
    condition     = !var.enable_producer || var.producer_target_service != null
    error_message = "var.producer_target_service is required when var.enable_producer is true"
  }
}

variable "producer_nat_cidr" {
  type        = string
  description = "CIDR range for the PSC NAT subnet (required when var.enable_producer is true)"
  default     = null

  validation {
    condition     = var.producer_nat_cidr == null || can(cidrhost(coalesce(var.producer_nat_cidr, "0.0.0.0/0"), 0))
    error_message = "var.producer_nat_cidr must be a valid CIDR range when set"
  }

  validation {
    condition     = !var.enable_producer || var.producer_nat_cidr != null
    error_message = "var.producer_nat_cidr is required when var.enable_producer is true"
  }
}

variable "producer_consumer_accept_list" {
  type = list(object({
    project_id_or_num = optional(string)
    network_url       = optional(string)
    connection_limit  = number
  }))
  description = "Consumers allowed to connect (ACCEPT_MANUAL): each entry names a project or a network and a connection limit"
  default     = []

  validation {
    condition = alltrue([
      for c in var.producer_consumer_accept_list :
      (c.project_id_or_num == null) != (c.network_url == null) && c.connection_limit >= 1
    ])
    error_message = "Each var.producer_consumer_accept_list entry must set exactly one of project_id_or_num or network_url, and a connection_limit of at least 1"
  }

  validation {
    condition     = !var.enable_producer || length(var.producer_consumer_accept_list) > 0
    error_message = "var.producer_consumer_accept_list must list at least one consumer when var.enable_producer is true"
  }
}

variable "producer_consumer_reject_list" {
  type        = list(string)
  description = "Consumer project IDs/numbers or network URLs that are always rejected"
  default     = []

  validation {
    condition     = alltrue([for c in var.producer_consumer_reject_list : length(trimspace(c)) > 0])
    error_message = "var.producer_consumer_reject_list must not contain empty strings"
  }
}

variable "producer_enable_proxy_protocol" {
  type        = bool
  description = "Prepend the PROXY protocol header so the producer can see the consumer's connection details"
  default     = false

  validation {
    condition     = var.producer_enable_proxy_protocol != null
    error_message = "var.producer_enable_proxy_protocol must be true or false"
  }
}

variable "producer_domain_names" {
  type        = list(string)
  description = "Optional DNS domain (ending in a dot) consumers get an automatic private zone for"
  default     = null

  validation {
    condition     = var.producer_domain_names == null || alltrue([for d in coalesce(var.producer_domain_names, []) : can(regex("\\.$", d))])
    error_message = "var.producer_domain_names entries must be fully qualified and end with a dot"
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
