terraform {
  cloud {
    organization = "Evironments"

    workspaces {
      name = "qa"
    }
  }
}
