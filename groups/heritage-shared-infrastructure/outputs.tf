output "rds_addresses" {
  # value = { for db, settings in var.rds_databases : db => aws_route53_record.rds[db].fqdn }
  value = { for dns in aws_route53_record.rds :
    dns.name => dns.fqdn
  }
}