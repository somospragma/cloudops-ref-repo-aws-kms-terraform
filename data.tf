data "aws_caller_identity" "current" {
  provider = aws.project
}

# Locals para manejar los principales adicionales
locals {
  # Solo agregar el rol de deployment si se proporciona
  additional_principals = var.deploy_role_arn != null ? [var.deploy_role_arn] : []
  
  # Combinar account ID con principales adicionales
  all_principals = concat(
    [data.aws_caller_identity.current.account_id],
    local.additional_principals
  )
}

data "aws_iam_policy_document" "root_policy" {
  provider = aws.project
  
  statement {
    sid       = "EnableRootAccountPermissions"
    actions   = ["kms:*"]
    resources = ["*"]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.all_principals
    }
  }
}

data "aws_iam_policy_document" "dynamic_policy" {
  provider = aws.project
  for_each = var.kms_config
  
  dynamic "statement" {
    for_each = each.value.statements
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
  provider = aws.project
  for_each = var.kms_config
  
  override_policy_documents = [
    data.aws_iam_policy_document.root_policy.json,
    data.aws_iam_policy_document.dynamic_policy[each.key].json
  ]
}