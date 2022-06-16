resource "aws_acm_certificate" "certificate_manager" {
  count             = var.use_https ? 1 : 0
  domain_name       = "${var.subdomain}.${var.hosted_zone_domain}"
  validation_method = "DNS"
}


resource "aws_route53_record" "record_set_certificate" {    
  for_each = {
    for dvo in aws_acm_certificate.certificate_manager[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  count                   = var.use_https ? 1 : 0
  certificate_arn         = aws_acm_certificate.certificate_manager[0].arn
  validation_record_fqdns = [for record in aws_route53_record.record_set_certificate : record.fqdn]
}
