data "oci_database_autonomous_databases" "mb_autonomous_databases" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  db_workload  = "DW"
  is_free_tier = "true"
}

resource "oci_database_autonomous_database" "mb_autonomous_database" {
  #Required
  admin_password           = "Testalwaysfree1"
  compartment_id           = var.compartment_ocid
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "demo"

  #Optional
  db_workload  = "DW"
  display_name = "mb_autonomous_database"

  freeform_tags = {
    "Department" = "Demo"
  }

  is_auto_scaling_enabled = "false"
  license_model           = "LICENSE_INCLUDED"
  is_free_tier            = "true"
}