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
  type        = map
}

# variable "instance_class" {
#   type        = string
#   description = "The type of instance for the RDS"
#   default     = "db.t3.medium"
# }

# variable "multi_az" {
#   type        = bool
#   description = "Whether the RDS is Multi-AZ"
#   default     = false
# }

# variable "backup_retention_period" {
#   type        = number
#   description = "The number of days to retain backups for - 0 to 35"
# }

# variable "allocated_storage" {
#   type        = number
#   description = "The amount of storage in GB to launch RDS with"
# }

# variable "maximum_storage" {
#   type        = number
#   description = "The maximum storage in GB to allow RDS to scale to"
# }

# ------------------------------------------------------------------------------
# RDS Engine Type Variables
# ------------------------------------------------------------------------------

# variable "engine" {
#   type        = string
#   description = "Engine type to be used for the RDS Instance (Database vendor) e.g. oracle-se2"
# }

# variable "major_engine_version" {
#   type        = string
#   description = "The major version of the database engine type e.g. 12.1"
# }
# variable "engine_version" {
#   type        = string
#   description = "The engine version provided by AWS RDS e.g. 12.1.0.2.v21"
# }
# variable "license_model" {
#   type        = string
#   description = "The license model for the engine, byol or license-include: https://aws.amazon.com/rds/oracle/faqs/"
# }

# ------------------------------------------------------------------------------
# Vault Variables
# ------------------------------------------------------------------------------
variable "vault_username" {
  type        = string
  description = "Username for connecting to Vault - usually supplied through TF_VARS"
}
variable "vault_password" {
  type        = string
  description = "Password for connecting to Vault - usually supplied through TF_VARS"
}