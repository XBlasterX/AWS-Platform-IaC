terraform {
  backend "s3" {
    bucket       = "274e628e-aws-platform-iac"
    key          = "environments/lab/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
