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
    "bcd" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_bcd : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
    "chdata" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_chdata : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
    "chd" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_chd : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
    "cics" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_cics : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
    "wck" = flatten([
      for sg_data in data.aws_security_group.rds_ingress_wck : {
        from_port                = 1521
        to_port                  = 1521
        protocol                 = "tcp"
        description              = "Access from ${sg_data.tags.Name}"
        source_security_group_id = sg_data.id
      }
    ])
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
