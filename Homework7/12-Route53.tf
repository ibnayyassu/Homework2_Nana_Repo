
data "aws_route53_zone" "main" {
  name         = "ibnayyassu.org"  # The domain name you want to look up
  private_zone = false
}


resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "ibnayyassu.org"
  type    = "A"

  alias {
    name                   = aws_lb.LizzoSunday_alb.dns_name
    zone_id                = aws_lb.LizzoSunday_alb.zone_id
    evaluate_target_health = true
  }
}
