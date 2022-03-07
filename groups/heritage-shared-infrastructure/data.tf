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

data "aws_security_group" "cics_asg" {
  filter {
    name   = "tag:Name"
    values = ["sgr-cics-asg*"]
  }
}

data "aws_security_group" "chd_bep_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-chd-bep-asg*"]
  }
}

data "aws_security_group" "chd_fe_asg" {
  count = var.environment == "live" ? 0 : 1
  filter {
    name   = "group-name"
    values = ["sgr-chd-fe-asg*"]
  }
}

data "aws_security_group" "wck_fe_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-wck-fe-asg*"]
  }
}

data "aws_security_group" "wck_bep_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-wck-bep-asg*"]
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
