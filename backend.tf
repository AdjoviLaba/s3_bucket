terraform {
  cloud {
    organization = "AWS_Training"

    workspaces {
      name = "s3_bucket"
    }
  }
}
