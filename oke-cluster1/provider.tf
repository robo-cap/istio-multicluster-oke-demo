provider "oci" {
  alias  = "home"
  region = var.home_region
  # config_file_profile = "ocisateam"
}

provider "oci" {
  region = var.region
  # config_file_profile = "ocisateam"
}

terraform {
  required_version = ">= 1.2.0"

  required_providers {

    oci = {
      configuration_aliases = [oci.home]
      source                = "oracle/oci"
      version               = ">= 6.20.0"
    }
  }
}