
// Give global read access to bucket
data "aws_iam_policy_document" "give_bucket_public_get_object_access" {
    # Default is version is "2012-10-17"
    statement {
        sid = "PublicReadGetObject"
        effect = "Allow"
        principals {
            type = "AWS"
            identifiers = ["*"]
        }

        actions = [
            "s3:GetObject",
        ]

        resources = [
            "arn:aws:s3:::${var.base_domain}/*",
        ]
    }
}
