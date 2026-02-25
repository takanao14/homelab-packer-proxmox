include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules"
}

inputs = {
  images = {
    "ubuntu-24.04-xrdp" = {
      file_name    = "${get_parent_terragrunt_dir()}/../images/ubuntu-24.04-xrdp.img"
      content_type = "iso"
      node_name    = "pve"
      datastore_id = "local"
    }
  }
}
