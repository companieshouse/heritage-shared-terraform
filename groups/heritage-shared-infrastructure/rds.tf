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

  ingress_with_source_security_group_id = local.rds_ingress_from_services[each.key]

  egress_rules = ["all-all"]
}

resource "aws_security_group_rule" "concourse_ingress" {
  for_each = toset(var.rds_ingress_concourse)

  description       = "Permit access to ${each.key} from Concourse"
  type              = "ingress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.concourse.id]
  security_group_id = module.rds_security_group[each.key].this_security_group_id
}

resource "aws_security_group_rule" "admin_ingress" {
  for_each = var.rds_databases

  description       = "Permit access to ${each.key} from admin ranges"
  type              = "ingress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.admin.id]
  security_group_id = module.rds_security_group[each.key].this_security_group_id
}

resource "aws_security_group_rule" "admin_ingress_oem" {
  for_each = var.rds_databases

  description       = "Permit access to Oracle Enterprise Manager ${each.key} from admin ranges"
  type              = "ingress"
  from_port         = 5500
  to_port           = 5500
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.admin.id]
  security_group_id = module.rds_security_group[each.key].this_security_group_id
}

resource "aws_security_group_rule" "sub_data_a_ingress_chd" {
  for_each = toset(local.sub_data_a_cidr)

  type              = "ingress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  description       = "Allow Oracle traffic from sub-data-a"
  cidr_blocks       = [each.value]
  security_group_id = module.rds_security_group["chd"].this_security_group_id
}

module "rds_app_security_group" {
  for_each = local.rds_databases_requiring_app_access

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${each.key}-rds-002"
  description = format("Security group for the %s RDS database", upper(each.key))
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = concat(each.value.rds_app_access)
  ingress_rules       = ["oracle-db-tcp"]

  egress_rules = ["all-all"]
}

resource "aws_security_group_rule" "dba_dev_ingress" {
  for_each = local.dba_dev_ingress_rules_map

  type              = "ingress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  cidr_blocks       = [each.value["cidr"]]
  security_group_id = each.value.sg_id
}

# ------------------------------------------------------------------------------
# RDS Instance
# ------------------------------------------------------------------------------
module "rds" {
  for_each = var.rds_databases

  source  = "terraform-aws-modules/rds/aws"
  version = "2.23.0" # Pinned version to ensure updates are a choice, can be upgraded if new features are available and required.

  create_db_parameter_group = "true"
  create_db_subnet_group    = "true"

  identifier                 = join("-", ["rds", each.key, var.environment, "001"])
  engine                     = lookup(each.value, "engine", "oracle-se2")
  major_engine_version       = lookup(each.value, "major_engine_version", "12.1")
  engine_version             = lookup(each.value, "engine_version", "12.1.0.2.v24")
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
  maintenance_window        = lookup(each.value, "rds_maintenance_window", "Mon:00:00-Mon:03:00")
  backup_window             = lookup(each.value, "rds_backup_window", "03:00-06:00")
  backup_retention_period   = lookup(each.value, "backup_retention_period", 7)
  skip_final_snapshot       = "false"
  final_snapshot_identifier = "${each.key}-final-deletion-snapshot"

  # Enhanced Monitoring
  monitoring_interval             = "30"
  monitoring_role_arn             = data.aws_iam_role.rds_enhanced_monitoring.arn
  enabled_cloudwatch_logs_exports = lookup(each.value, "rds_log_exports", null)

  performance_insights_enabled          = var.environment == "live" ? true : false
  performance_insights_kms_key_id       = data.aws_kms_key.rds.arn
  performance_insights_retention_period = 7

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  # RDS Security Group
  vpc_security_group_ids = flatten([
    module.rds_security_group[each.key].this_security_group_id,
    data.aws_security_group.rds_shared.id,
    [for key, value in module.rds_app_security_group : value.this_security_group_id if key == each.key],
  ])


  # DB subnet group
  subnet_ids = data.aws_subnet_ids.data.ids

  # DB Parameter group
  family = join("-", [each.value.engine, each.value.major_engine_version])

  parameters = var.parameter_group_settings[each.key]

  options = concat([
    {
      option_name                    = "OEM"
      port                           = "5500"
      vpc_security_group_memberships = [module.rds_security_group[each.key].this_security_group_id]
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
  ], each.value.per_instance_options)

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

module "rds_start_stop_schedule" {
  source = "git@github.com:companieshouse/terraform-modules//aws/rds_start_stop_schedule?ref=tags/1.0.131"

  for_each = var.rds_start_stop_schedule

  rds_schedule_enable = lookup(each.value, "rds_schedule_enable", false)

  rds_instance_id    = module.rds[each.key].this_db_instance_id
  rds_start_schedule = lookup(each.value, "rds_start_schedule")
  rds_stop_schedule  = lookup(each.value, "rds_stop_schedule")
}

module "rds_cloudwatch_alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/oracledb_cloudwatch_alarms?ref=tags/1.0.173"

  for_each = var.rds_cloudwatch_alarms

  db_instance_id        = module.rds[each.key].this_db_instance_id
  db_instance_shortname = upper(each.key)
  alarm_actions_enabled = lookup(each.value, "alarm_actions_enabled")
  alarm_name_prefix     = "Oracle RDS"
  alarm_topic_name      = lookup(each.value, "alarm_topic_name")
  alarm_topic_name_ooh  = lookup(each.value, "alarm_topic_name_ooh")
}
