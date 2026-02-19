# ------------------------------------------------------------------------------
# AWS Variables
# ------------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS Account in which resources will be administered"
}

# ------------------------------------------------------------------------------
# AWS Variables - Shorthand
# ------------------------------------------------------------------------------

variable "account" {
  type        = string
  description = "Short version of the name of the AWS Account in which resources will be administered"
}

variable "region" {
  type        = string
  description = "Short version of the name of the AWS region in which resources will be administered"
}

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "The name of the environment"
}

# ------------------------------------------------------------------------------
# RDS Variables
# ------------------------------------------------------------------------------
variable "rds_databases" {
  type = any
}

variable "rds_ingress_groups" {
  type        = map(list(string))
  description = "A map whose keys represent RDS instances and whose values are lists of strings representing security group filter patterns"
}

variable "parameter_group_settings" {
  type        = map(list(any))
  description = "A map whose keys represent RDS instances and whose values are a list of parameters that will be set in the RDS instance parameter group"
}

variable "rds_start_stop_schedule" {
  type        = map(map(any))
  description = "A map whose keys represent RDS instances and whose values define configuration for RDS start/stop schedules"
}

variable "rds_cloudwatch_alarms" {
  type        = map(map(any))
  description = "A map whose keys represent RDS instances and whose values define RDS CloudWatch Alarms configuration"
}

variable "rds_ingress_concourse" {
  default     = []
  description = "A list of RDS instance keys that will be configured to permit connectivity from Concourse"
  type        = list(string)
}
