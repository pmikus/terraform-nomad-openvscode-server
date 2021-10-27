locals {
  datacenters = join(",", var.datacenters)
  envs        = join("\n", concat([], var.envs))
  upstreams   = jsonencode(var.upstreams)
}

data "template_file" "nomad_job_code_server" {
  template = file("${path.module}/conf/nomad/code_server.hcl")
  vars = {
    auto_promote              = var.auto_promote
    auto_revert               = var.auto_revert
    canary                    = var.canary
    cert                      = var.cert
    cpu                       = var.cpu
    cpu_proxy                 = var.resource_proxy.cpu
    datacenters               = local.datacenters
    envs                      = local.envs
    group_count               = var.group_count
    host                      = var.host
    image                     = var.image
    job_name                  = var.job_name
    max_parallel              = var.max_parallel
    memory                    = var.memory
    memory_proxy              = var.resource_proxy.memory
    password                  = var.password
    port_static               = var.port_static
    region                    = var.region
    service_name              = var.service_name
    use_canary                = var.use_canary
    use_host_volume           = var.use_host_volume
    upstreams                 = local.upstreams
    use_vault_kms             = var.kms_variables.use_vault_kms
    use_vault_provider        = var.vault_secret.use_vault_provider
    vault_address             = var.kms_variables.vault_address
    vault_kms_approle_kv      = var.kms_variables.vault_kms_approle_kv
    vault_kms_key_name        = var.kms_variables.vault_kms_key_name
    vault_kv_policy_name      = var.vault_secret.vault_kv_policy_name
    vault_kv_path             = var.vault_secret.vault_kv_path
    volume_destination        = var.volume_destination
    volume_source             = var.volume_source
  }
}

resource "nomad_job" "nomad_job_code_server" {
  jobspec = data.template_file.nomad_job_code_server.rendered
  detach  = false
}
