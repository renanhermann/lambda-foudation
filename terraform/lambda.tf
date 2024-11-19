resource "aws_lambda_function" "control_ec2_rds" {
  filename         = "start-stop-instances.zip" # Caminho do código compactado
  function_name    = "control_ec2_rds_instances"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"

  # Variáveis de ambiente
  environment {
    variables = {
      EC2_INSTANCE_IDS = "ECAWS1APPWT010" # ID da EC2
      RDS_INSTANCE_IDS = "db-uat-zurichonline" # ID do RDS
    }
  }

  # Dependência para role
  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}