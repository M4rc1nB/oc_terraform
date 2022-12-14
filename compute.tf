resource "oci_core_instance" "oci_instance1" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "oci-01"
  shape               = var.instance_shape

  shape_config {
    ocpus = 3
    memory_in_gbs = 18
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.mb_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "oci-01"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.uk-london-1.aaaaaaaacd6wvghqqeocouaahlveplsl4bkutztyz6rstu5bag6limxr5rxa"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = "${base64encode(templatefile("./scripts/mybootscript.sh",
    {
      MSSQL_SA_PASSWORD = base64decode(data.oci_secrets_secretbundle.ddclient.secret_bundle_content.0.content)
      DDCLIENT_TOKEN = base64decode(data.oci_secrets_secretbundle.ddclient.secret_bundle_content.0.content)
      CODE_SRV_PASSWORD = base64decode(data.oci_secrets_secretbundle.codeserver.secret_bundle_content.0.content)
      CODE_SRV_SU_PASSWORD = base64decode(data.oci_secrets_secretbundle.codeserversu.secret_bundle_content.0.content) 
      DATA_VOLUME_DEVICE = "/dev/sdd"   
    }
      ))}"
  }
}

/* resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
} */

data "oci_secrets_secretbundle" "ddclient" {
  #secret_id = var.secret_ocid
  secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaawubmyiaajp37l6xiyxdyu5geg3ypabzx4lrsxo24c2iru5ahg7wa"
}

data "oci_secrets_secretbundle" "mssql" {
  secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaawubmyiaadibg35stnh2ifaadg3rpkxvsprpz6fwxhb7auak3qbuq"
}

data "oci_secrets_secretbundle" "codeserver" {
  secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaawubmyiaant2d2zudjvgb5gqcamdxgdppqp4wq22p2kwtdzttlllq"
}

data "oci_secrets_secretbundle" "codeserversu" {
  secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaawubmyiaa7ru3utu5otpihpfrgi4wjy5yzsysvtc6awhnj5qhgmza"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 3
}

# See https://docs.oracle.com/iaas/images/
/* data "oci_core_images" "test_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical-Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
} */

resource "oci_core_volume" "oci1_block_volume" {

  availability_domain  = data.oci_identity_availability_domain.ad.name
  compartment_id       = var.compartment_ocid
  display_name         = "oci_instance1-block-volume"
  size_in_gbs          = 50

}

/* resource "oci_core_volume" "test_volume" {
    #Required
    compartment_id = var.compartment_id

    #Optional
    autotune_policies {
        #Required
        autotune_type = var.volume_autotune_policies_autotune_type

        #Optional
        max_vpus_per_gb = var.volume_autotune_policies_max_vpus_per_gb
    }
    availability_domain = var.volume_availability_domain
    backup_policy_id = data.oci_core_volume_backup_policies.test_volume_backup_policies.volume_backup_policies.0.id
    block_volume_replicas {
        #Required
        availability_domain = var.volume_block_volume_replicas_availability_domain

        #Optional
        display_name = var.volume_block_volume_replicas_display_name
    }
    defined_tags = {"Operations.CostCenter"= "42"}
    display_name = var.volume_display_name
    freeform_tags = {"Department"= "Finance"}
    is_auto_tune_enabled = var.volume_is_auto_tune_enabled
    kms_key_id = oci_kms_key.test_key.id
    size_in_gbs = var.volume_size_in_gbs
    size_in_mbs = var.volume_size_in_mbs
    source_details {
        #Required
        id = var.volume_source_details_id
        type = var.volume_source_details_type
    }
    vpus_per_gb = var.volume_vpus_per_gb
    block_volume_replicas_deletion = true
} */

/* resource "oci_core_volume_attachment" "test_volume_attachment" {
    #Required
    attachment_type = var.volume_attachment_attachment_type
    instance_id = oci_core_instance.test_instance.id
    volume_id = oci_core_volume.test_volume.id

    #Optional
    device = var.volume_attachment_device
    display_name = var.volume_attachment_display_name
    encryption_in_transit_type = var.volume_attachment_encryption_in_transit_type
    is_agent_auto_iscsi_login_enabled = var.volume_attachment_is_agent_auto_iscsi_login_enabled
    is_pv_encryption_in_transit_enabled = var.volume_attachment_is_pv_encryption_in_transit_enabled
    is_read_only = var.volume_attachment_is_read_only
    is_shareable = var.volume_attachment_is_shareable
    use_chap = var.volume_attachment_use_chap
} */

resource "oci_core_volume_attachment" "oci1_block_volume_attachement" {
  attachment_type = "paravirtualized" #iscsi
  instance_id     = oci_core_instance.oci_instance1.id
  volume_id       = oci_core_volume.oci1_block_volume.id
  device          = "/dev/oracleoci/oraclevdag"
}