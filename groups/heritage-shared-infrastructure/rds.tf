# ------------------------------------------------------------------------------
# RDS Security Group and rules
# ------------------------------------------------------------------------------
module "rds_security_group" {
  for_each = var.rds_databases

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${each.key}-rds-001"
  description = format("Security group for the %s RDS database", upper(each.key))
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = local.rds_ingress_cidrs
  ingress_rules       = ["oracle-db-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5500
      to_port     = 5500
      protocol    = "tcp"
      description = "Oracle Enterprise Manager"
      cidr_blocks = join(",", local.rds_ingress_cidrs)
    }
  ]

  egress_rules = ["all-all"]
}

# ------------------------------------------------------------------------------
# RDS Instance
# ------------------------------------------------------------------------------
module "rds" {
  for_each = var.rds_databases

  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  create_db_parameter_group = "true"
  create_db_subnet_group    = "true"

  identifier                 = join("-", ["rds", each.key, var.environment, "001"])
  engine                     = lookup(each.value, "engine", "oracle-se2")
  major_engine_version       = lookup(each.value, "major_engine_version", "12.1")
  engine_version             = lookup(each.value, "engine_version", "12.1.0.2.v21")
  auto_minor_version_upgrade = lookup(each.value, "auto_minor_version_upgrade", false)
  license_model              = lookup(each.value, "license_model", "license-included")
  instance_class             = lookup(each.value, "instance_class", "db.t3.medium")
  allocated_storage          = lookup(each.value, "allocated_storage", 20)
  storage_type               = lookup(each.value, "storage_type", null)
  iops                       = lookup(each.value, "iops", null)
  multi_az                   = lookup(each.value, "multi_az", false)
  storage_encrypted          = true
  kms_key_id                 = data.aws_kms_key.rds.arn

  name     = upper(each.key)
  username = local.rds_data[each.key]["admin-username"]
  password = local.rds_data[each.key]["admin-password"]
  port     = "1521"

  deletion_protection       = true
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "03:00-06:00"
  backup_retention_period   = lookup(each.value, "backup_retention_period", 7)
  skip_final_snapshot       = "false"
  final_snapshot_identifier = "${each.key}-final-deletion-snapshot"

  # Enhanced Monitoring
  monitoring_interval = "30"
  monitoring_role_arn = data.aws_iam_role.rds_enhanced_monitoring.arn

  # RDS Security Group
  vpc_security_group_ids = [
    module.rds_security_group[each.key].this_security_group_id,
    data.aws_security_group.rds_shared.id
  ]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.data.ids

  # DB Parameter group
  family = join("-", [each.value.engine, each.value.major_engine_version])

  parameters = var.parameter_group_settings

  options = [
    {
      option_name                    = "OEM"
      port                           = "5500"
      vpc_security_group_memberships = [module.rds_security_group[each.key].this_security_group_id]
    },
    {
      option_name = "JVM"
    },
    {
      option_name = "SQLT"
      version     = "2018-07-25.v1"
      option_settings = [
        {
          name  = "LICENSE_PACK"
          value = "N"
        },
      ]
    },
  ]

  timeouts = {
    "create" : "80m",
    "delete" : "80m",
    "update" : "80m"
  }

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", format("%s-DBA-Support", upper(each.key))
    )
  )
}