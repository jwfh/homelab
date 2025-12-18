data "aws_ssm_parameter" "app_configuration" {
  name            = "/apps/${var.environment}/${var.app_name}/configuration"
  with_decryption = true
}
