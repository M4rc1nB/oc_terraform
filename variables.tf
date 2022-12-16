variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaa4jxpivou2v7qawgmduzj2w6c3ama6g7z46hx44jfjyhh5hpfgeda"
}

variable "user_ocid" {
  default = "ocid1.user.oc1..aaaaaaaaauuq7p57dc3zjrdlxk52hmxcv7pv54thzkanujawxbou2nooml4q"
}

variable "fingerprint" {
  default = "22:23:1e:d6:b8:2d:24:ad:27:58:07:93:1e:1f:44:d6"
}

variable "private_key_path" {
  default = ""
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsXdAAfwT5pWXrjhSNDEFOnr8rbt52XkdMM81rTvmLQO8hc7ROqAp5yFnkk6C/EeGvwvk3qu8sOlDohxsq/npT98WqzwX47fijHyzXeYdSDGSh+bWoxXH4EZhEX0TvBKeJSAGNaYf5N3KrIwCzoNm3lnAvE0RceU+p7xFAzvQ6edTh2amJqTkJkHu9PMb0MTvHxKA8YMdwzfGlzjeHuzbYELELo/nMFaAUZih7QnDyaxNHb4Ilmphwbfte68753f4ckOVRet3iYa5Bl4xEl57lqLPz/sCqzl0gj9PUXJFEjKXEVnlD5bsCc3F3UyJ9tjebNgEMQjV2Lpch3MzLw8r7"
}

variable "compartment_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaa4jxpivou2v7qawgmduzj2w6c3ama6g7z46hx44jfjyhh5hpfgeda"
}

variable "region" {
  default = "uk-london-1"
}

variable "instance_ocpus" { default = 1 }

variable "instance_shape_config_memory_in_gbs" { default = 6 }

variable "generate_ssh_key_pair" {
  description = "Auto-generate SSH key pair"
  type        = string
  default     = false
}


variable "instance_shape" {
  description = "Shape of the instance"
  type        = string
  default     = "VM.Standard.A1.Flex"
}


variable "use_tenancy_level_policy" {
  description = "Compute instance to access all resources at tenancy level"
  type        = bool
  default     = true
}



