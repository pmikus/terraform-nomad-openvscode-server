# Nomad

variable "datacenters" {
  description = "Specifies the list of DCs to be considered placing this task"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "Specifies the list of DCs to be considered placing this task"
  type        = string
  default     = "global"
}

variable "volume_source" {
  description = "The name of the volume to request"
  type        = string
  default     = "persistence"
}

# Code Server
variable "auto_promote" {
  description = "Specifies if the job should auto-promote to the canary version"
  type        = bool
  default     = true
}

variable "auto_revert" {
  description = "Specifies if the job should auto-revert to the last stable job"
  type        = bool
  default     = true
}

variable "canary" {
  description = "Equal to the count of the task group allows blue/green depl."
  type        = number
  default     = 1
}

variable "cert" {
  description = "Use certificate for Code Server"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "Specifies the CPU required to run this task in MHz"
  type        = number
  default     = 1000
}

variable "envs" {
  description = "Code Server environment variables"
  type        = list(string)
  default     = []
}

variable "group_count" {
  description = "Specifies the number of the task groups running under this one"
  type        = number
  default     = 1
}

variable "host" {
  description = "Code Server host"
  type        = string
  default     = "127.0.0.1"
}

variable "image" {
  description = "The Docker image to run"
  type        = string
  default     = "pmikus/docker-code-server-base:v3.12.0"
}

variable "job_name" {
  description = "Specifies a name for the job"
  type        = string
  default     = "code-server"
}

variable "kms_variables" {
  type = object({
    use_vault_kms        = string
    vault_address        = string,
    vault_kms_approle_kv = string,
    vault_kms_key_name   = string
  })
  description = "Set of properties to be able to transit secrets in vault"
  default = {
    use_vault_kms        = false
    vault_address        = "",
    vault_kms_approle_kv = "",
    vault_kms_key_name   = ""
  }
}

variable "max_parallel" {
  description = "Specifies the maximum number of updates to perform in parallel"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Specifies the memory required in MB"
  type        = number
  default     = 1024
}

variable "password" {
  description = "Code Server password"
  type        = string
  default     = "28cc31eb07175f727e155ec8"
  sensitive   = true
}

variable "port_static" {
  description = "Specifies the static TCP/UDP port to allocate"
  type        = number
  default     = 8443
}

variable "resource_proxy" {
  description = "Code Server proxy resources"
  type = object({
    cpu    = number,
    memory = number
  })
  default = {
    cpu    = 2000,
    memory = 1024
  }
  validation {
    condition     = var.resource_proxy.cpu >= 200 && var.resource_proxy.memory >= 128
    error_message = "Proxy resource must be at least: cpu=200, memory=128."
  }
}

variable "service_name" {
  description = "Specifies the name this service will be advertised in Consul"
  type        = string
  default     = "coder"
}

variable "upstreams" {
  type = list(object({
    service_name = string,
    port         = number,
  }))
  description = "List of upstream services"
  default     = []
}

variable "use_canary" {
  description = "Uses canary deployment for Code Server"
  type        = bool
  default     = false
}

variable "use_host_volume" {
  description = "Use Nomad host volume feature"
  type        = bool
  default     = true
}

variable "vault_secret" {
  type = object({
    use_vault_provider        = bool,
    vault_kv_policy_name      = string,
    vault_kv_path             = string
  })
  description = "Set of properties to be able to fetch secret from vault"
  default = {
    use_vault_provider        = true
    vault_kv_policy_name      = "kv-secret"
    vault_kv_path             = "secret/data/coder"
  }
}

variable "volume_destination" {
  description = "Specifies where the volume should be mounted inside the task"
  type        = string
  default     = "/home/coder/"
}

