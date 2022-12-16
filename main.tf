locals {
  common_tags = {
    Reference = "marcin-oci"
  }
}

module "network" {
  source                = "./modules/network"
  target_compartment_id = var.compartment_ocid
  common_tags           = local.common_tags
}

module "storage" {
  source                = "./modules/storage"
  target_compartment_id = var.compartment_ocid
  common_tags           = local.common_tags
}

module "compute" {
  source                              = "./modules/compute"
  region                              = var.region
  tenancy_ocid                        = var.tenancy_ocid
  target_compartment_id               = var.compartment_ocid
  vcn_id                              = module.network.vcn.id
  subnet_id                           = module.network.subnet.id
  instance_shape                      = "VM.Standard.E2.1.Micro" #var.instance_shape #
  instance_ocpus                      = 1
  instance_shape_config_memory_in_gbs = 1
  data_volume_device                  = "/dev/oracleoci/oraclevdag"
  generate_ssh_key_pair               = var.generate_ssh_key_pair
  ssh_public_key                      = var.ssh_public_key
  use_tenancy_level_policy            = var.use_tenancy_level_policy
  common_tags                         = local.common_tags
}

module "database" {
  source                = "./modules/database"
  target_compartment_id = var.compartment_ocid
  common_tags           = local.common_tags
}

module "vault" {
  source                = "./modules/vault"
  target_compartment_id = var.compartment_ocid
  vault_display_name    = "marcin_vault"
  vault_vault_type      = "DEFAULT" #"VIRTUAL_PRIVATE"
  common_tags           = local.common_tags
}