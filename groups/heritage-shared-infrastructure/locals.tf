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
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend CHD"
        source_security_group_id = data.aws_security_group.chd_bep_asg.id
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
      },
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Backend CHD"
        source_security_group_id = data.aws_security_group.chd_bep_asg.id
      }
    ],
    "cics" = [
      {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "CICs App"
        source_security_group_id = data.aws_security_group.cics_asg.id
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

  rds_databases_requiring_app_access = {
    for key, value in var.rds_databases : key => value if length(value.rds_app_access) > 0
  }

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
