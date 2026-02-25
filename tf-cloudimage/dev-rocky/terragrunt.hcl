include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules"
}

inputs = {
  images = {
    "rocky-10-custom" = {
      file_name    = "${get_parent_terragrunt_dir()}/../images/rocky-10-custom.img"
      content_type = "iso"
      node_name    = "pve"
      datastore_id = "local"
    }
  }
}
