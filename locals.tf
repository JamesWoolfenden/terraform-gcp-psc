locals {
  # Each part is enabled by passing its object. Producer and consumer
  # resources are regional; the Google APIs endpoint is global.
  consumer_count    = var.consumer == null ? 0 : 1
  google_apis_count = var.google_apis == null ? 0 : 1
  producer_count    = var.producer == null ? 0 : 1
}
