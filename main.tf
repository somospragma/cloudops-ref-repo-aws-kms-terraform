data "aws_caller_identity" "current" {
  provider    = aws.project
}

resource "aws_kms_key" "key" {
  provider    = aws.project
  count               = length(var.kms_config) > 0 ? length(var.kms_config) : 0
  description         = var.kms_config[count.index].description
  enable_key_rotation = var.kms_config[count.index].enable_key_rotation
  policy              = data.aws_iam_policy_document.combined[count.index].json
  tags = merge({ Name = "${join("-", tolist([var.client, var.environment, "kms", var.kms_config[count.index].application_id, var.service,count.index + 1]))}" })
}

resource "aws_kms_alias" "alias" {
  provider    = aws.project
  count         = length(var.kms_config) > 0 ? length(var.kms_config) : 0
  name          = "alias/${join("-", tolist([var.client, var.environment, "kms", var.kms_config[count.index].application_id, var.service,count.index + 1]))}"
  target_key_id = aws_kms_key.key[count.index].key_id
}

data "aws_iam_policy_document" "root_policy" {
  provider    = aws.project
  count = length(var.kms_config) > 0 ? 1 : 0
  statement {
    sid       = "IAM_Users"
    actions   = ["kms:*"]
    resources = ["*"]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "dynamic_policy" {
  provider    = aws.project
  count = length(var.kms_config) > 0 ? length(var.kms_config) : 0
  dynamic "statement" {
    for_each = var.kms_config[count.index].statements
    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
      effect    = statement.value["effect"]
      principals {
        type        = statement.value["type"]
        identifiers = statement.value["identifiers"]
      }

      dynamic "condition" {
        for_each = statement.value["condition"]
        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}


data "aws_iam_policy_document" "combined" {
  provider    = aws.project
  count = length(var.kms_config) > 0 ? length(var.kms_config) : 0
  override_policy_documents = [
    data.aws_iam_policy_document.root_policy[0].json,
    data.aws_iam_policy_document.dynamic_policy[count.index].json
  ]
}
