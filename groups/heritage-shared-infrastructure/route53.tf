resource "aws_route53_record" "rds" {
  for_each = { for key, database in var.rds_databases : key => database if key != "sess" }

  zone_id = data.aws_route53_zone.private_zone.zone_id
  name    = format("%s%s", each.key, "db")
  type    = "CNAME"
  ttl     = "300"
  records = [module.rds[each.key].this_db_instance_address]
}