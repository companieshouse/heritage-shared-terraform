data "aws_vpc" "vpc" {
  tags = {
    Name = "vpc-${var.aws_account}"
  }
}

data "aws_subnet_ids" "data" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["sub-data-*"]
  }
}

data "aws_security_group" "rds_shared" {
  filter {
    name   = "group-name"
    values = ["sgr-rds-shared-001*"]
  }
}

data "aws_security_group" "xml_fe_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-xml-fe-asg*"]
  }
}

data "aws_security_group" "xml_fe_tux" {
  filter {
    name   = "tag:Name"
    values = ["xml-frontend-tuxedo-${var.environment}"]
  }
}

data "aws_security_group" "xml_bep_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-xml-bep-asg*"]
  }
}

data "aws_security_group" "ewf_fe_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-ewf-fe-asg*"]
  }
}

data "aws_security_group" "ewf_fe_tux" {
  filter {
    name   = "tag:Name"
    values = ["ewf-frontend-tuxedo-${var.environment}"]
  }
}

data "aws_security_group" "ewf_bep_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-ewf-bep-asg*"]
  }
}

data "aws_security_group" "adminsites" {
  filter {
    name   = "tag:Name"
    values = ["sgr-admin-sites-asg*"]
  }
}

data "aws_route53_zone" "private_zone" {
  name         = local.internal_fqdn
  private_zone = true
}

data "aws_iam_role" "rds_enhanced_monitoring" {
  name = "irol-rds-enhanced-monitoring"
}

data "aws_kms_key" "rds" {
  key_id = "alias/kms-rds"
}

data "vault_generic_secret" "bcd_rds" {
  path = "applications/${var.aws_profile}/bcd/rds"
}

data "vault_generic_secret" "chdata_rds" {
  path = "applications/${var.aws_profile}/chdata/rds"
}

data "vault_generic_secret" "chd_rds" {
  path = "applications/${var.aws_profile}/chd/rds"
}

data "vault_generic_secret" "wck_rds" {
  path = "applications/${var.aws_profile}/wck/rds"
}

data "vault_generic_secret" "cics_rds" {
  path = "applications/${var.aws_profile}/cics/rds"
}

data "vault_generic_secret" "fes_rds" {
  path = "applications/${var.aws_profile}/fes/rds"
}

data "vault_generic_secret" "internal_cidrs" {
  path = "aws-accounts/network/internal_cidr_ranges"
}

# ------------------------------------------------------------------------------
# CHD BEP Data
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_subnet_ids" "application" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["sub-application-*"]
  }
}

data "aws_security_group" "nagios_shared" {
  filter {
    name   = "group-name"
    values = ["sgr-nagios-inbound-shared-*"]
  }
}

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "vault_generic_secret" "s3_releases" {
  path = "aws-accounts/shared-services/s3"
}

data "vault_generic_secret" "kms_keys" {
  path = "aws-accounts/${var.aws_account}/kms"
}

data "vault_generic_secret" "security_kms_keys" {
  path = "aws-accounts/security/kms"
}

data "vault_generic_secret" "security_s3_buckets" {
  path = "aws-accounts/security/s3"
}

data "vault_generic_secret" "chd_ec2_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/ec2"
}

#data "vault_generic_secret" "chd_bep_data" {
#  path = "applications/${var.aws_account}-${var.aws_region}/${var.application}/backend"
#}

data "aws_ami" "chd_bep" {
  owners      = [data.vault_generic_secret.account_ids.data["development"]]
  most_recent = var.bep_ami_name == "chd-backend-*" ? true : false

  filter {
    name = "name"
    values = [
      var.bep_ami_name,
    ]
  }

  filter {
    name = "state"
    values = [
      "available",
    ]
  }
}

data "template_file" "bep_userdata" {
  template = file("${path.module}/templates/bep_user_data.tpl")

#  vars = {
#    REGION             = var.aws_region
#    CHD_BACKEND_INPUTS = local.chd_bep_data
#    ANSIBLE_INPUTS     = jsonencode(local.chd_bep_ansible_inputs)
#    CHD_CRON_ENTRIES   = var.account == "hlive" ? "#No Entries" : templatefile("${path.module}/templates/bep_cron.tpl", { "USER" = "", "PASSWORD" = "" })
#  }
  vars = {
    REGION             = var.aws_region
    CHD_BACKEND_INPUTS = ""
    ANSIBLE_INPUTS     = jsonencode(local.chd_bep_ansible_inputs)
    CHD_CRON_ENTRIES   = var.account == "hlive" ? "#No Entries" : templatefile("${path.module}/templates/bep_cron.tpl", { "USER" = "", "PASSWORD" = "" })
  }
}

data "template_cloudinit_config" "bep_userdata_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.bep_userdata.rendered
  }
}
