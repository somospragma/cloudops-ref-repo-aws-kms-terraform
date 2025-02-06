# output "kms_info" {
#   value = [for key in aws_kms_alias.alias : {
#     "key_id" : key.target_key_id, 
#     "key_alias" : key.name, 
#     "key_arn" : key.arn
#     }]
# }

# output "kms_info" {
#   value = [for i, key in aws_kms_key.key : {
#     "key_id": key.key_id,
#     "key_arn": key.arn,  # Este es el ARN directo de la llave
#     "key_alias": aws_kms_alias.alias[i].name,
#     "key_alias_arn": aws_kms_alias.alias[i].arn
#   }]
# }

# output "kms_info" {
#   value = [for i, key in aws_kms_key.key : {
#     "key_id": key.key_id,
#     "key_arn": key.arn,          # ARN directo de la llave
#     "key_alias": aws_kms_alias.alias[i].name,
#     "key_alias_arn": aws_kms_alias.alias[i].arn,  # ARN del alias
#     "target_key_id": aws_kms_alias.alias[i].target_key_id  # ID de la llave objetivo
#   }]
# }

# Output para la información de las llaves KMS
output "kms_info" {
  value = [for i, key in aws_kms_key.key : {
    "key_id": key.key_id,
    "key_arn": key.arn
  }]
}

# Output para la información de los alias
output "kms_alias_info" {
  value = [for i, alias in aws_kms_alias.alias : {
    "name": alias.name,
    "arn": alias.arn,
    "target_key_id": alias.target_key_id
  }]
}