# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  chs_application_cidrs = var.environment == "development" ? [] : values(data.vault_generic_secret.chs_cidrs.data)
  sess_rds_data = data.vault_generic_secret.sess_rds.data
  accountIds    = data.vault_generic_secret.account_ids.data

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  ceu_fe_subnet_cidrs = jsondecode(data.vault_generic_secret.ceu_fe_outputs.data["ceu-frontend-web-subnets-cidrs"])

  default_tags = {
    Terraform   = "true"
    Region      = var.aws_region
    Account     = var.aws_account
    Environment = var.environment
    Repository  = "heritage-shared-terraform"
  }
}
