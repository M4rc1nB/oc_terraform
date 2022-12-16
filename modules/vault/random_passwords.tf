resource "random_password" "ddclient" {
  length           = 16
  special          = true
  override_special = "_%!()<>"
}