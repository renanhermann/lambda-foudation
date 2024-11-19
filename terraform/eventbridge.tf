# Log Group para Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.control_ec2_rds.function_name}"
  retention_in_days = 14
}

# EventBridge Rule para desligar instâncias
resource "aws_eventbridge_rule" "stop_instances" {
  name                = "stop_instances_rule"
  schedule_expression = "cron(0 23 * * ? *)" # 23h todos os dias (UTC-5)
  description         = "Desliga EC2 e RDS diariamente às 23h UTC-5"
}

# EventBridge Rule para ligar instâncias
resource "aws_eventbridge_rule" "start_instances" {
  name                = "start_instances_rule"
  schedule_expression = "cron(0 5 * * ? *)" # 5h todos os dias (UTC-5)
  description         = "Liga EC2 e RDS diariamente às 5h UTC-5"
}


# Permitir EventBridge invocar Lambda
resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowEventBridgeInvokeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.control_ec2_rds.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_eventbridge_rule.stop_instances.arn
}

resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowEventBridgeInvokeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.control_ec2_rds.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_eventbridge_rule.start_instances.arn
}

# Associar regras EventBridge à Lambda
resource "aws_eventbridge_target" "stop_target" {
  rule      = aws_eventbridge_rule.stop_instances.name
  arn       = aws_lambda_function.control_ec2_rds.arn
  input     = jsonencode({ "action": "stop" })
}

resource "aws_eventbridge_target" "start_target" {
  rule      = aws_eventbridge_rule.start_instances.name
  arn       = aws_lambda_function.control_ec2_rds.arn
  input     = jsonencode({ "action": "start" })
}