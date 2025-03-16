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

resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

resource "null_resource" "s3_sync" {
    depends_on = [module.lambda_function.aws_lambda_function]
    provisioner "local-exec" {
        command = "aws s3 sync ./../public/ s3://${var.bucket_name}/public/ --region ${local.region} && aws s3 sync ./../.next/static/ s3://${var.lambda_function_name}-${local.account_id}-${local.region}-static/_next/static/ --region ${local.region}"
    }
    
    lifecycle {
      replace_triggered_by = [
        null_resource.always_run
      ]
    }
}