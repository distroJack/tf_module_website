
// Grabs user from aws provider
data "aws_canonical_user_id" "current_user" {}

// ${base_domain} bucket with all the configuration needed
//---------------------------------------------------------------
// domain bucket w/logging 
resource "aws_s3_bucket" "logging_domain_bucket" {
  bucket = var.base_domain

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "Group"
    permissions = ["READ_ACP"]
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  logging {
    target_bucket = aws_s3_bucket.logs_bucket[count.index].id
    target_prefix = "/"
  }

  depends_on = [aws_s3_bucket.logs_bucket]

  force_destroy = true
  // IF true: enable
  count = var.enable_logging ? 1 : 0
}

// domain bucket w/out logging 
resource "aws_s3_bucket" "logless_domain_bucket" {
  bucket = var.base_domain

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "Group"
    permissions = ["READ_ACP"]
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  force_destroy = true
  // IF true: disable
  count = var.enable_logging ? 0 : 1 // I present terraforms negation operation :(((
}

data "aws_s3_bucket" "domain_bucket" {
  bucket     = var.base_domain
  depends_on = [aws_s3_bucket.logging_domain_bucket, aws_s3_bucket.logless_domain_bucket]
}
//---------------------------------------------------------------

// Apply global read access policy to bucket
resource "aws_s3_bucket_policy" "domain_bucket_policy" {
  bucket = data.aws_s3_bucket.domain_bucket.id
  policy = data.aws_iam_policy_document.give_bucket_public_get_object_access.json
}

// use aws CLI to sync static files with bucket
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${var.static_path} s3://${data.aws_s3_bucket.domain_bucket.id}"
  }
  depends_on = [data.aws_s3_bucket.domain_bucket]

  triggers = {
    always_run = timestamp()
  }
}

// www.${base_domain} bucket redirects to ${base_domain}
resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${data.aws_s3_bucket.domain_bucket.id}"
  website {
    redirect_all_requests_to = data.aws_s3_bucket.domain_bucket.website_endpoint
  }
}

// log bucket that records site access to ${base_domain} bucket
resource "aws_s3_bucket" "logs_bucket" {
  bucket        = "logs.${var.base_domain}"
  acl           = "log-delivery-write"
  force_destroy = true
  // IF true: enable
  count = var.enable_logging ? 1 : 0
}