terraform {
  cloud {
    organization = "AWS_Training"

    workspaces {
      name = "s3bucket1"
    }
  }
}
