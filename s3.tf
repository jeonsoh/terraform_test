resource "aws_s3_bucket" "zcp_registry_storage" {
  bucket = lower("${local.cluster_name}-registry")
}

resource "aws_s3_bucket_public_access_block" "zcp_registry_storage" {
  bucket = aws_s3_bucket.zcp_registry_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "zcp_tsdb_storage" {
  bucket = lower("${local.cluster_name}-tsdb")
}

resource "aws_s3_bucket_public_access_block" "zcp_tsdb_storage" {
  bucket = aws_s3_bucket.zcp_tsdb_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "zcp_rules_storage" {
  bucket = lower("${local.cluster_name}-rules")
}

resource "aws_s3_bucket_public_access_block" "zcp_rules_storage" {
  bucket = aws_s3_bucket.zcp_rules_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "zcp_alertmanager_storage" {
  bucket = lower("${local.cluster_name}-alertmanager")
}

resource "aws_s3_bucket_public_access_block" "zcp_alertmanager_storage" {
  bucket = aws_s3_bucket.zcp_alertmanager_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}