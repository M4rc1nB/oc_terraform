
terraform {
  backend "http" {
    update_method = "PUT"
    address       = "https://objectstorage.uk-london-1.oraclecloud.com/p/rSNLGA1var3_0UWszqlbq5d1kQ1BTX7RkDwWY5b-oO65328LA7vHsRqpIym1S-ys/n/lr6e3ldmihvt/b/terraform/o/infra/terraform.tfstate"
  }
}