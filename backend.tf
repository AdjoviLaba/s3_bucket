terraform {
  cloud {
    organization = "Environments"

    workspaces {
      name = "dev"
    }
  }
}
