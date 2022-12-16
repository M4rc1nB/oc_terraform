variable "bucket_access_type" {
  type    = string
  default = "NoPublicAccess"
}

resource "oci_objectstorage_bucket" "tf_bucket" {
  compartment_id = var.target_compartment_id
  name           = "artefacts"
  namespace      = "lr6e3ldmihvt"
  access_type    = var.bucket_access_type
}