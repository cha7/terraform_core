module "s3_bucket" {
    source = "terraform-aws-modules/s3-bucket/aws"

    bucket = var.bucket_name

    versioning = {
         enabled = false
    }

    block_public_acls   = true
    block_public_policy = false
    restrict_public_buckets = false
    
    website = {
        index_document = "index.html"
        error_document = "error.html"
    }
    attach_policy           = true
    policy                  = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*",
      "arn:aws:s3:::${var.bucket_name}"
    ]

    condition {
        test     = "StringEquals"
        variable = "aws:Referer"
        values = [var.api_id]
    }
  }
}