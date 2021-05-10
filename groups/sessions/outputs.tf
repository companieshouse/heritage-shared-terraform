output "rds_address" {
  value = aws_route53_record.sessions_rds.fqdn
}
