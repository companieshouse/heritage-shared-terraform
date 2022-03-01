# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  admin_cidrs   = values(data.vault_generic_secret.internal_cidrs.data)
  sess_rds_data = data.vault_generic_secret.sess_rds.data
  accountIds    = data.vault_generic_secret.account_ids.data

  ceu_fe_secgroup_Id       = data.vault_generic_secret.ceu_fe_outputs.data["ceu-frontend-security-group"]
  ceu_fe_secgroup_rds_rule = var.environment == "live" ? local.accountIds["pci-services"] / local.ceu_fe_secgroup_Id : local.ceu_fe_secgroup_Id

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
