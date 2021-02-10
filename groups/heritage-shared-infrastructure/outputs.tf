output "rds_addresses" {
  value = { for db, settings in var.rds_databases : db => aws_route53_record.rds[db].fqdn }
}

output "rds_endpoints" {
  value = { for db, settings in var.rds_databases : db => module.rds[db].this_db_instance_address }

}

output "rds_database_names" {
  value = { for db, settings in var.rds_databases : db => module.rds[db].this_db_instance_name }
}