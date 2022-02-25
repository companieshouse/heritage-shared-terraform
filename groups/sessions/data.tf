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

data "aws_security_group" "ewf_fe_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-ewf-fe-asg*"]
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

data "aws_security_group" "ceu_bep_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-ceu-bep-asg*"]
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

data "vault_generic_secret" "sess_rds" {
  path = "applications/${var.aws_profile}/sess/rds"
}

data "vault_generic_secret" "internal_cidrs" {
  path = "aws-accounts/network/internal_cidr_ranges"
}
