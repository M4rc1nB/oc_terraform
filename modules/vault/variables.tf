variable "target_compartment_id" {
  description = "OCID of the compartment where the VCN is being created"
  type        = string
}

variable "common_tags" {
  description = "Tags"
  type        = map(string)
}

variable "vault_display_name" {}

variable "vault_vault_type" {}