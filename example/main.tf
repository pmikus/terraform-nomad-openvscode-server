# For convenience in simple configurations, a child module automatically
# inherits default (un-aliased) provider configurations from its parent.
# This means that explicit provider blocks appear only in the root module,
# and downstream modules can simply declare resources for that provider
# and have them automatically associated with the root provider
# configurations.

module "code_server" {
  source = "../"
  providers = {
    nomad = nomad.vagrant
  }

  # nomad
  datacenters   = ["vagrant"]
  volume_source = "volume-glacier1-1"

  # code-server
  cert            = true
  image           = "pmikus/docker-code-server-base:latest"
  job_name        = "code-server"
  group_count     = 1
  password        = "28cc31eb07175f727e155ec8"
  port_static     = 8080
  service_name    = "coder"
  use_host_volume = true
  use_canary      = true
  vault_secret = {
    use_vault_provider   = false,
    vault_kv_policy_name = "kv-secret",
    vault_kv_path        = "secret/data/coder"
  }
  volume_destination = "/home/coder/"
}

