include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules"
}

inputs = {
  images = {
    "ubuntu-2404-custom" = {
      file_name    = "${get_parent_terragrunt_dir()}/../images/ubuntu-24.04-custom.img"
      content_type = "iso"
      node_name    = "node1"
      datastore_id = "local"
    }
  }
}
