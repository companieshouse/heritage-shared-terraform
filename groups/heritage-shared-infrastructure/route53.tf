resource "aws_route53_record" "rds" {
  for_each = var.rds_databases
  
  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = format("%s%s", each.key, "db")
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds[each.key].this_db_instance_address]
}