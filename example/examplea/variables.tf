variable "consumer_service_attachment" {
  type        = string
  description = "Service attachment published by another producer that the example consumer endpoint connects to"

  validation {
    condition     = can(regex("projects/[^/]+/regions/[^/]+/serviceAttachments/[^/]+$", var.consumer_service_attachment))
    error_message = "var.consumer_service_attachment must look like projects/P/regions/R/serviceAttachments/NAME"
  }
}
