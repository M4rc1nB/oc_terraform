data "oci_database_autonomous_databases" "marcin_autonomous_databases" {
  #Required
  compartment_id = var.target_compartment_id

  #Optional
  db_workload  = "DW"
  is_free_tier = "true"
}

resource "oci_database_autonomous_database" "marcin_autonomous_database" {
  #Required
  admin_password           = base64decode(data.oci_secrets_secretbundle.marcin_autonomous_database.secret_bundle_content.0.content)
  compartment_id           = var.target_compartment_id
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "demo"

  #Optional
  db_workload  = "DW"
  display_name = "marcin_autonomous_database"

  freeform_tags = {
    "Department" = "Demo"
  }

  is_auto_scaling_enabled = "false"
  license_model           = "LICENSE_INCLUDED"
  is_free_tier            = "true"
}

data "oci_secrets_secretbundle" "marcin_autonomous_database" {
  secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaawubmyiaadxhp6mpvt4vd2obpaowcaaijc2mf34das3rmuskh2tka"
}

