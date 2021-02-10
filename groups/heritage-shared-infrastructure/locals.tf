# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs = values(data.vault_generic_secret.internal_cidrs.data)

  rds_data = {
    bcd    = data.vault_generic_secret.bcd_rds.data
    chdata = data.vault_generic_secret.chdata_rds.data
  }

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  rds_ingress_cidrs = concat(local.admin_cidrs, var.rds_onpremise_access)

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
