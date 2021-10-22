# For convenience in simple configurations, a child module automatically
# inherits default (un-aliased) provider configurations from its parent.
# This means that explicit provider blocks appear only in the root module,
# and downstream modules can simply declare resources for that provider
# and have them automatically associated with the root provider
# configurations.

module "openvscode" {
  source = "../"
  providers = {
    nomad = nomad.vagrant
  }

  # nomad
  datacenters   = ["vagrant"]
  volume_source = "volume-glacier1-1"

  # openvscode
  job_name     = "openvscode"
  group_count  = 1
  service_name = "openvscode"
  host         = "http://10.0.2.15"
  port         = 3000
  image        = "gitpod/openvscode-server"
  vault_secret = {
    use_vault_provider        = false,
    vault_kv_policy_name      = "kv-secret",
    vault_kv_path             = "secret/data/openvscode"
  }
  volume_destination = "/home/workspace/"
  use_host_volume    = false
  use_canary         = true
}
