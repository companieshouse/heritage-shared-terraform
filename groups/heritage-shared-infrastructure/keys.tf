# ------------------------------------------------------------------------------
# CHD Key Pair
# ------------------------------------------------------------------------------
resource "aws_key_pair" "chd_keypair" {
  key_name   = var.application
  public_key = local.chd_ec2_data["public-key"]
}

