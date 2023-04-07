terraform {
  cloud {
    organization = "Environments"

    workspaces {
      name = var.workspace
    }
  }
}
