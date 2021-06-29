# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs = values(data.vault_generic_secret.internal_cidrs.data)

  rds_data = {
    bcd    = data.vault_generic_secret.bcd_rds.data
    chdata = data.vault_generic_secret.chdata_rds.data
    chd    = data.vault_generic_secret.chd_rds.data
    wck    = data.vault_generic_secret.wck_rds.data
    cics   = data.vault_generic_secret.cics_rds.data
    fes    = data.vault_generic_secret.fes_rds.data
  }

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  rds_ingress_from_services = {
    "bcd" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend XML"
        source_security_group_id = data.aws_security_group.xml_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend XML"
        source_security_group_id = data.aws_security_group.xml_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo XML"
        source_security_group_id = data.aws_security_group.xml_fe_tux.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend EWF"
        source_security_group_id = data.aws_security_group.ewf_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Admin Sites"
        source_security_group_id = data.aws_security_group.adminsites.id
      }
    ],
    "chdata" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend XML"
        source_security_group_id = data.aws_security_group.xml_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend XML"
        source_security_group_id = data.aws_security_group.xml_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo XML"
        source_security_group_id = data.aws_security_group.xml_fe_tux.id
      }
    ],
    "chd" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend EWF"
        source_security_group_id = data.aws_security_group.ewf_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      }
    ],
    "wck" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend EWF"
        source_security_group_id = data.aws_security_group.ewf_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      }
    ],
    "cics" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend EWF"
        source_security_group_id = data.aws_security_group.ewf_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      }
    ],
    "fes" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend EWF"
        source_security_group_id = data.aws_security_group.ewf_bep_asg.id
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Frontend Tuxedo EWF"
        source_security_group_id = data.aws_security_group.ewf_fe_tux.id
      }
    ]
  }

#  chd_bep_data = data.vault_generic_secret.chd_bep_data.data_json
  chd_ec2_data = data.vault_generic_secret.chd_ec2_data.data

  kms_keys_data          = data.vault_generic_secret.kms_keys.data
  security_kms_keys_data = data.vault_generic_secret.security_kms_keys.data
  logs_kms_key_id        = local.kms_keys_data["logs"]
  ssm_kms_key_id         = local.security_kms_keys_data["session-manager-kms-key-arn"]

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  session_manager_bucket_name = local.security_s3_data["session-manager-bucket-name"]

  bep_cw_logs = { for log, map in var.bep_cw_logs : log => merge(map, { "log_group_name" = "${var.application}-bep-${log}" }) }
  bep_log_groups = compact([for log, map in local.bep_cw_logs : lookup(map, "log_group_name", "")])

  chd_bep_ansible_inputs = {
    s3_bucket_releases         = local.s3_releases["release_bucket_name"]
    s3_bucket_configs          = local.s3_releases["config_bucket_name"]
    heritage_environment       = var.environment
    version                    = var.bep_app_release_version
    default_nfs_server_address = var.nfs_server
    mounts_parent_dir          = var.nfs_mount_destination_parent_dir
    mounts                     = var.nfs_mounts
    region                     = var.aws_region
    cw_log_files               = local.bep_cw_logs
    cw_agent_user              = "root"
  }


  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
