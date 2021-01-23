
// Best to use established route 53 zone
// AWS doesn't properly update DNS servers once a zone is deleted
// This forces manual effort no matter what. I prefer one and done on start.
data "aws_route53_zone" "website_zone" {
  name =  var.base_domain
}

// record for ${base_domain} site
resource "aws_route53_record" "domain_record" {
    zone_id = data.aws_route53_zone.website_zone.zone_id
    name    = data.aws_s3_bucket.domain_bucket.id
    type    = "A"

    alias {
        name = "s3-website-us-east-1.amazonaws.com" # Why AWS changed this? IDK but it displeases Jack greatly :((((
        zone_id = data.aws_s3_bucket.domain_bucket.hosted_zone_id
        evaluate_target_health = false
    }
}

// record for www.${base_domain} site
resource "aws_route53_record" "www_domain_record" {
    zone_id = data.aws_route53_zone.website_zone.zone_id
    name    = aws_s3_bucket.www_bucket.id
    type    = "A"

    alias {
        name = "s3-website-us-east-1.amazonaws.com"
        zone_id =  aws_s3_bucket.www_bucket.hosted_zone_id
        evaluate_target_health = false
    }
}