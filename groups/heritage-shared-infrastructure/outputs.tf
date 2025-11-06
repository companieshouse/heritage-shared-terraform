output "rds_addresses" {
  value = { for dns in aws_route53_record.rds :
    dns.name => dns.fqdn
  }
}
