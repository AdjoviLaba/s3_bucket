terraform {
  cloud {
    organization = "Evironments"

    workspaces {
      name = "s3bucket1"
    }
  }
}
