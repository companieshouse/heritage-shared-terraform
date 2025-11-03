# Heritage Shared Resources 

Hosts the following RDS instances as these are shared across multiple services.
* BCD
* CHData
* CHD
* CICS
* FES

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0, < 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 0.3, < 4.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 0.3, < 4.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 2.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | 2.23.0 |
| <a name="module_rds_app_security_group"></a> [rds\_app\_security\_group](#module\_rds\_app\_security\_group) | terraform-aws-modules/security-group/aws | ~> 3.0 |
| <a name="module_rds_cloudwatch_alarms"></a> [rds\_cloudwatch\_alarms](#module\_rds\_cloudwatch\_alarms) | git@github.com:companieshouse/terraform-modules//aws/oracledb_cloudwatch_alarms | tags/1.0.173 |
| <a name="module_rds_security_group"></a> [rds\_security\_group](#module\_rds\_security\_group) | terraform-aws-modules/security-group/aws | ~> 3.0 |
| <a name="module_rds_start_stop_schedule"></a> [rds\_start\_stop\_schedule](#module\_rds\_start\_stop\_schedule) | git@github.com:companieshouse/terraform-modules//aws/rds_start_stop_schedule | tags/1.0.131 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group_rule.admin_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.admin_ingress_oem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.concourse_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.dba_dev_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.sub_data_a_ingress_chd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ec2_managed_prefix_list.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_ec2_managed_prefix_list.concourse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_iam_role.rds_enhanced_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_kms_key.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_route53_zone.private_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_security_group.rds_ingress_bcd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.rds_ingress_chd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.rds_ingress_chdata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.rds_ingress_cics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.rds_shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_subnet.sub_data_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet_ids.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [vault_generic_secret.bcd_rds](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.chd_rds](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.chdata_rds](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.cics_rds](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |
| [vault_generic_secret.fes_rds](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | Short version of the name of the AWS Account in which resources will be administered | `string` | n/a | yes |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | The name of the AWS Account in which resources will be administered | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | The AWS profile to use | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which resources will be administered | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_parameter_group_settings"></a> [parameter\_group\_settings](#input\_parameter\_group\_settings) | A map whose keys represent RDS instances and whose values are a list of parameters that will be set in the RDS instance parameter group | `map(list(any))` | n/a | yes |
| <a name="input_rds_cloudwatch_alarms"></a> [rds\_cloudwatch\_alarms](#input\_rds\_cloudwatch\_alarms) | A map whose keys represent RDS instances and whose values define RDS CloudWatch Alarms configuration | `map(map(any))` | n/a | yes |
| <a name="input_rds_databases"></a> [rds\_databases](#input\_rds\_databases) | ------------------------------------------------------------------------------ RDS Variables ------------------------------------------------------------------------------ | `any` | n/a | yes |
| <a name="input_rds_ingress_concourse"></a> [rds\_ingress\_concourse](#input\_rds\_ingress\_concourse) | A list of RDS instance keys that will be configured to permit connectivity from Concourse | `list(string)` | `[]` | no |
| <a name="input_rds_ingress_groups"></a> [rds\_ingress\_groups](#input\_rds\_ingress\_groups) | A map whose keys represent RDS instances and whose values are lists of strings representing security group filter patterns | `map(list(string))` | n/a | yes |
| <a name="input_rds_start_stop_schedule"></a> [rds\_start\_stop\_schedule](#input\_rds\_start\_stop\_schedule) | A map whose keys represent RDS instances and whose values define configuration for RDS start/stop schedules | `map(map(any))` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Short version of the name of the AWS region in which resources will be administered | `string` | n/a | yes |
| <a name="input_sub_data_access"></a> [sub\_data\_access](#input\_sub\_data\_access) | A boolean value indicating whether to allow sub-data-a access ingress to the RDS database | `bool` | `false` | no |
| <a name="input_vault_password"></a> [vault\_password](#input\_vault\_password) | Password for connecting to Vault - usually supplied through TF\_VARS | `string` | n/a | yes |
| <a name="input_vault_username"></a> [vault\_username](#input\_vault\_username) | Username for connecting to Vault - usually supplied through TF\_VARS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_addresses"></a> [rds\_addresses](#output\_rds\_addresses) | n/a |
<!-- END_TF_DOCS -->