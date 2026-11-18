locals {
  # Producer and consumer resources are regional; the Google APIs endpoint is global.
  consumer_count    = var.enable_consumer ? 1 : 0
  google_apis_count = var.enable_google_apis ? 1 : 0
  producer_count    = var.enable_producer ? 1 : 0
}
