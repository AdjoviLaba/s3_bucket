terraform {
  cloud {
    organization = "Evironments"

    workspaces {
      name = "dev"
    }
  }
}
