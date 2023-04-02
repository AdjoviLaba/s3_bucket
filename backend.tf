terraform {
  cloud {
    organization = "Noelie_Tf_Cloud"

    workspaces {
      name = "github-action"
    }
  }
}