resource "oci_kms_vault" "marcin_vault" {
  #Required
  compartment_id = var.target_compartment_id
  display_name   = var.vault_display_name
  vault_type     = var.vault_vault_type

  freeform_tags = var.common_tags
}

resource "oci_kms_key" "marcin_key" {
  #Required
  compartment_id = var.target_compartment_id
  display_name   = "marcin_key"
  key_shape {
    #Required
    algorithm = "AES"
    length    = "16"

  }
  management_endpoint = oci_kms_vault.marcin_vault.management_endpoint

  #Optional
  freeform_tags = var.common_tags
}

resource "oci_vault_secret" "random_secret" {
  #Required
  compartment_id = var.target_compartment_id
  secret_content {
    #Required
    content      = base64encode(random_password.ddclient.result)
    content_type = "BASE64"
  }
  secret_name = "ddclient-oci"
  vault_id    = oci_kms_vault.marcin_vault.id

  #Optional
  freeform_tags = var.common_tags
  key_id        = oci_kms_key.marcin_key.id
  secret_rules {
    #Required
    rule_type                              = "SECRET_REUSE_RULE"
    is_enforced_on_deleted_secret_versions = true
  }
}