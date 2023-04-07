terraform {
  cloud {
    organization = "Environments"

    workspaces {
      name = "${terraform.workspace}"
    }
  }
}
