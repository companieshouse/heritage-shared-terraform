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

data "aws_security_group" "xml_bep_asg" {
  filter {
    name   = "group-name"
    values = ["sgr-xml-bep-asg*"]
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

data "vault_generic_secret" "internal_cidrs" {
  path = "aws-accounts/network/internal_cidr_ranges"
}