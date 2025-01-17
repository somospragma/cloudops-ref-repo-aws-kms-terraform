################################################################
# Module KMS
################################################################
module "kms" {
  source = "./module/kms"
  client      = var.client
  service     = var.service_name_kms
  environment = var.environment

  kms_config = [
    {
      description         = "Key for securing RDS cluster data"
      enable_key_rotation = var.enable_key_rotation
      statements = [
        {
          sid         = "AllowRDSAccess"
          actions     = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
          resources   = ["*"]
          effect      = "Allow"
          type        = "AWS"
          identifiers = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
          condition = []
        }
      ]
      application_id = "${var.project}"
    }
  ]
}
  
