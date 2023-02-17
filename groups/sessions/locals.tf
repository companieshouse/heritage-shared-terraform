# ------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------
locals {
  sess_rds_data = data.vault_generic_secret.sess_rds.data
  accountIds    = data.vault_generic_secret.account_ids.data

  internal_fqdn = format("%s.%s.aws.internal", split("-", var.aws_account)[1], split("-", var.aws_account)[0])

  ceu_fe_subnet_cidrs = jsondecode(data.vault_generic_secret.ceu_fe_outputs.data["ceu-frontend-web-subnets-cidrs"])

  rds_ingress_from_services = flatten([
    for sg_data in data.aws_security_group.rds_ingress : {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Access from ${sg_data.tags.Name}"
      source_security_group_id = sg_data.id
    }
  ])

  default_tags = {
    Terraform = "true"
    Region    = var.aws_region
    Account   = var.aws_account
  }
}
