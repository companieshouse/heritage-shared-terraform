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

data "aws_subnet" "sub_data_a" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["sub-data-a"]
  }
}

data "aws_security_group" "rds_shared" {
  filter {
    name   = "group-name"
    values = ["sgr-rds-shared-001*"]
  }
}

data "aws_security_group" "rds_ingress_bcd" {
  count = length(var.rds_ingress_groups["bcd"])
  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups["bcd"][count.index]]
  }
}

data "aws_security_group" "rds_ingress_chd" {
  count = length(var.rds_ingress_groups["chd"])
  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups["chd"][count.index]]
  }
}

data "aws_security_group" "rds_ingress_chdata" {
  count = length(var.rds_ingress_groups["chdata"])
  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups["chdata"][count.index]]
  }
}

data "aws_security_group" "rds_ingress_cics" {
  count = length(var.rds_ingress_groups["cics"])
  filter {
    name   = "group-name"
    values = [var.rds_ingress_groups["cics"][count.index]]
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

data "vault_generic_secret" "cics_rds" {
  path = "applications/${var.aws_profile}/cics/rds"
}

data "vault_generic_secret" "fes_rds" {
  path = "applications/${var.aws_profile}/fes/rds"
}

data "aws_ec2_managed_prefix_list" "admin" {
  name = "administration-cidr-ranges"
}

data "aws_ec2_managed_prefix_list" "concourse" {
  name = "shared-services-management-cidrs"
}
