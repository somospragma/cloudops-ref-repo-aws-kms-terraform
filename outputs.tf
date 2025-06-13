# Output para la información de las llaves KMS
output "kms_info" {
  description = "Información detallada de todas las claves KMS creadas, incluyendo ID y ARN"
  value = {
    for k, key in aws_kms_key.key : k => {
      key_id  = key.key_id,
      key_arn = key.arn
    }
  }
}

# Output para la información de los alias
output "kms_alias_info" {
  description = "Información detallada de todos los alias de KMS creados, incluyendo nombre, ARN y ID de la clave objetivo"
  value = {
    for k, alias in aws_kms_alias.alias : k => {
      name          = alias.name,
      arn           = alias.arn,
      target_key_id = alias.target_key_id
    }
  }
}

# Output combinado para facilitar el uso
output "kms_complete_info" {
  description = "Información completa de las claves KMS y sus alias, combinada en una estructura fácil de usar"
  value = {
    for k, key in aws_kms_key.key : k => {
      key_id       = key.key_id,
      key_arn      = key.arn,
      alias_name   = aws_kms_alias.alias[k].name,
      alias_arn    = aws_kms_alias.alias[k].arn,
      description  = key.description,
      tags         = key.tags
    }
  }
}


output "debug_info" {
  value = {
    caller_account = data.aws_caller_identity.current.account_id
    caller_arn     = data.aws_caller_identity.current.arn
    caller_user_id = data.aws_caller_identity.current.user_id
  }
}