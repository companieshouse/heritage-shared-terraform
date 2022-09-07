# ------------------------------------------------------------------------------
# RDS Security Group and rules
# ------------------------------------------------------------------------------
module "rds_security_group" {

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-sessions-rds-001"
  description = "Security group for the sessions RDS database"
  vpc_id      = data.aws_vpc.vpc.id

  ingress_cidr_blocks = concat(local.admin_cidrs, var.rds_onpremise_access)
  ingress_rules       = ["oracle-db-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5500
      to_port     = 5500
      protocol    = "tcp"
      description = "Oracle Enterprise Manager"
      cidr_blocks = join(",", concat(local.admin_cidrs, var.rds_onpremise_access))
    },
    {
      from_port   = "1521"
      to_port     = "1521"
      protocol    = "tcp"
      description = "Frontend CEU"
      cidr_blocks = join(",", local.ceu_fe_subnet_cidrs)
    }
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Frontend EWF"
      source_security_group_id = data.aws_security_group.ewf_fe_asg.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Backend EWF"
      source_security_group_id = data.aws_security_group.ewf_bep_asg.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Frontend Admin sites"
      source_security_group_id = data.aws_security_group.adminsites.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Backend CHD"
      source_security_group_id = data.aws_security_group.chd_bep_asg.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Backend CEU"
      source_security_group_id = data.aws_security_group.ceu_bep_asg.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Frontend CHD"
      source_security_group_id = data.aws_security_group.chd_fe_asg.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Frontend WCK"
      source_security_group_id = data.aws_security_group.wck_fe_asg.id
    },
    {
      from_port                = 1521
      to_port                  = 1521
      protocol                 = "tcp"
      description              = "Backend WCK"
      source_security_group_id = data.aws_security_group.wck_bep_asg.id
    },
  ]

  egress_rules = ["all-all"]
}

# ------------------------------------------------------------------------------
# RDS Instance
# ------------------------------------------------------------------------------
module "sessions_rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.23.0" # Pinned version to ensure updates are a choice, can be upgraded if new features are available and required.

  create_db_parameter_group = "true"
  create_db_subnet_group    = "true"

  identifier                 = join("-", ["rds", var.identifier, var.environment, "001"])
  engine                     = "oracle-se2"
  major_engine_version       = var.major_engine_version
  engine_version             = var.engine_version
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  license_model              = var.license_model
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  storage_type               = var.storage_type
  iops                       = var.iops
  multi_az                   = var.multi_az
  storage_encrypted          = true
  kms_key_id                 = data.aws_kms_key.rds.arn

  name     = upper(var.name)
  username = local.sess_rds_data["admin-username"]
  password = local.sess_rds_data["admin-password"]
  port     = "1521"

  deletion_protection       = true
  maintenance_window        = var.rds_maintenance_window
  backup_window             = var.rds_backup_window
  backup_retention_period   = var.backup_retention_period
  skip_final_snapshot       = "false"
  final_snapshot_identifier = "${var.identifier}-final-deletion-snapshot"

  # Enhanced Monitoring
  monitoring_interval             = "30"
  monitoring_role_arn             = data.aws_iam_role.rds_enhanced_monitoring.arn
  enabled_cloudwatch_logs_exports = var.rds_log_exports

  performance_insights_enabled          = var.environment == "live" ? true : false
  performance_insights_kms_key_id       = data.aws_kms_key.rds.arn
  performance_insights_retention_period = 7

  # RDS Security Group
  vpc_security_group_ids = [
    module.rds_security_group.this_security_group_id,
    data.aws_security_group.rds_shared.id
  ]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.data.ids

  # DB Parameter group
  family = join("-", ["oracle-se2", var.major_engine_version])

  parameters = var.parameter_group_settings

  options = [
    {
      option_name                    = "OEM"
      port                           = "5500"
      vpc_security_group_memberships = [module.rds_security_group.this_security_group_id]
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
    {
      option_name = "Timezone"
      option_settings = [
        {
          name  = "TIME_ZONE"
          value = "Europe/London"
        },
      ]
    }
  ]

  timeouts = {
    "create" : "80m",
    "delete" : "80m",
    "update" : "80m"
  }

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.identifier)}-DBA-Support"
    )
  )
}

module "rds_start_stop_schedule" {
  source = "git@github.com:companieshouse/terraform-modules//aws/rds_start_stop_schedule?ref=tags/1.0.131"

  rds_schedule_enable = var.rds_schedule_enable

  rds_instance_id     = module.sessions_rds.this_db_instance_id
  rds_start_schedule  = var.rds_start_schedule
  rds_stop_schedule   = var.rds_stop_schedule
}

module "rds_cloudwatch_alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/rds_cloudwatch_alarms?ref=tags/1.0.167"

  rds_instance_id        = module.sessions_rds.this_db_instance_id
  rds_instance_shortname = upper(var.name)
  alarm_actions_enabled  = var.alarm_actions_enabled
  alarm_topic_name       = var.alarm_topic_name
  alarm_topic_name_ooh   = var.alarm_topic_name_ooh
}
