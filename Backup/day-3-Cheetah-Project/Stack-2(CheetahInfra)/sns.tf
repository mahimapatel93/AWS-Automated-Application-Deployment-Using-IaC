module "sns" {
  source = "./localmodules/noifications"

  env_name            = var.env_name
  lambda_function_arn = module.lambda.lambda_function_arn
}