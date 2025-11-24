output "namespace" {
  value = "${var.environment}-${var.app_name}"
}

output "configuration" {
  value = jsondecode(data.aws_ssm_parameter.app_configuration.value)
}
