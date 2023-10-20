resource "aws_api_gateway_domain_name" "api" {
  domain_name = "${var.subdomain}.${var.domain}"
  regional_certificate_arn = aws_acm_certificate.api.arn
  endpoint_configuration {
    types   = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.api]
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api-gateway.id
  domain_name = aws_api_gateway_domain_name.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
#   api_mapping_key = "v1"
}



