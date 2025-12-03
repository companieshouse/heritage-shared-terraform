# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  rds_data = {
    bcd    = data.vault_generic_secret.bcd_rds.data
    chdata = data.vault_generic_secret.chdata_rds.data
    chd    = data.vault_generic_secret.chd_rds.data
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
  }

  rds_databases_requiring_app_access = {
    for key, value in var.rds_databases : key => value if length(value.rds_app_access) > 0
  }

  chd_dba_dev_ingress_cidrs_list    = jsondecode(nonsensitive(data.vault_generic_secret.chd_rds.data_json))["dba-dev-cidrs"]
  chdata_dba_dev_ingress_cidrs_list = jsondecode(nonsensitive(data.vault_generic_secret.chdata_rds.data_json))["dba-dev-cidrs"]

  dba_dev_ingress_instances_map = {
    chd    = local.chd_dba_dev_ingress_cidrs_list,
    chdata = local.chdata_dba_dev_ingress_cidrs_list,
  }

  dba_dev_ingress_rules_map = merge([
    for instance, cidrs in local.dba_dev_ingress_instances_map : {
      for idx, cidr in cidrs : "${instance}_${idx}" => {
        cidr  = cidr
        sg_id = module.rds_security_group[instance].security_group_id
      }
    }
  ]...)

  default_tags = {
    Terraform   = "true"
    Region      = var.aws_region
    Account     = var.aws_account
    Environment = var.environment
    Repository  = "heritage-shared-terraform"

  }
}
