resource "aws_kms_key" "key" {
  provider            = aws.project
  for_each            = var.kms_config
  description         = each.value.description
  enable_key_rotation = each.value.enable_key_rotation
  policy              = data.aws_iam_policy_document.combined[each.key].json
  
  tags = merge(
    {
      Name = local.kms_names[each.key]
    },
    each.value.additional_tags
  )
}

resource "aws_kms_alias" "alias" {
  provider      = aws.project
  for_each      = var.kms_config
  name          = local.kms_aliases[each.key]
  target_key_id = aws_kms_key.key[each.key].key_id
}
