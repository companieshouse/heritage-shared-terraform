# ------------------------------------------------------------------------------
# CHD Security Group and rules
# ------------------------------------------------------------------------------
module "chd_bep_asg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.application}-bep-asg-001"
  description = "Security group for the ${var.application} backend asg"
  vpc_id      = data.aws_vpc.vpc.id

  egress_rules = ["all-all"]

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-BEP-Support"
    )
  )
}

resource "aws_cloudwatch_log_group" "chd_bep" {
  for_each = local.bep_cw_logs

  name              = each.value["log_group_name"]
  retention_in_days = lookup(each.value, "log_group_retention", var.bep_default_log_group_retention_in_days)
  kms_key_id        = lookup(each.value, "kms_key_id", local.logs_kms_key_id)

  tags = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-BEP-Support"
    )
  )
}

# ASG Scheduled Shutdown
resource "aws_autoscaling_schedule" "bep-schedule-stop" {
  count = var.bep_schedule_stop ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-bep-scheduled-shutdown"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "00 20 * * 1-5" #Mon-Fri at 8pm
  autoscaling_group_name = module.bep_asg.this_autoscaling_group_name
}

# ASG Scheduled Startup
resource "aws_autoscaling_schedule" "bep-schedule-start" {
  count = var.bep_schedule_start ? 1 : 0

  scheduled_action_name  = "${var.aws_account}-${var.application}-bep-scheduled-startup"
  min_size               = var.bep_min_size
  max_size               = var.bep_max_size
  desired_capacity       = var.bep_desired_capacity
  recurrence             = "00 06 * * 1-5" #Mon-Fri at 6am
  autoscaling_group_name = module.bep_asg.this_autoscaling_group_name
}

# ASG Module
module "bep_asg" {
  source = "git@github.com:companieshouse/terraform-modules//aws/terraform-aws-autoscaling?ref=tags/1.0.36"

  name = "${var.application}-bep"
  # Launch configuration
  lc_name       = "${var.application}-bep-launchconfig"
  image_id      = data.aws_ami.chd_bep.id
  instance_type = var.bep_instance_size
  security_groups = [
    module.chd_bep_asg_security_group.this_security_group_id,
    data.aws_security_group.nagios_shared.id
  ]
  root_block_device = [
    {
      volume_size = "40"
      volume_type = "gp2"
      encrypted   = true
      iops        = 0
    },
  ]
  # Auto scaling group
  asg_name                       = "${var.application}-bep-asg"
  vpc_zone_identifier            = data.aws_subnet_ids.application.ids
  health_check_type              = "EC2"
  min_size                       = var.bep_min_size
  max_size                       = var.bep_max_size
  desired_capacity               = var.bep_desired_capacity
  health_check_grace_period      = 300
  wait_for_capacity_timeout      = 0
  force_delete                   = true
  enable_instance_refresh        = true
  refresh_min_healthy_percentage = 50
  refresh_triggers               = ["launch_configuration"]
  key_name                       = aws_key_pair.chd_keypair.key_name
  termination_policies           = ["OldestLaunchConfiguration"]
  iam_instance_profile           = module.chd_bep_profile.aws_iam_instance_profile.name
  user_data_base64               = data.template_cloudinit_config.bep_userdata_config.rendered

  tags_as_map = merge(
    local.default_tags,
    map(
      "ServiceTeam", "${upper(var.application)}-BEP-Support"
    )
  )
}

