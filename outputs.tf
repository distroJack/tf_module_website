
// TODO what needs to be output?

// base bucket access for future content insertion
output "domain_bucket" {
  value = data.aws_s3_bucket.domain_bucket
}

// host zone access
output "route_53_site_zone" {
  value = data.aws_route53_zone.website_zone
}