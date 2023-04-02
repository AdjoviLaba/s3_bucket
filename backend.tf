terraform {
  cloud {
    organization = "AWS_Training"

    workspaces {
      name = "workflow"
    }
  }
}
