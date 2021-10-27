<!-- markdownlint-disable MD041 -->

# Terraform-nomad-code-server
Terraform-nomad-code-server module is IaaC - infrastructure as a
code. Module contains a nomad job with [Code Server](https://www.gitpod.io).
- [consul](https://www.consul.io/docs/) service integration.
- [docker driver](https://www.nomadproject.io/docs/drivers/docker.html)

## Compatibility
| Software | OSS Version | Enterprise Version |
| :------- | :---------- | :-------- |
| Terraform | 1.0.7 or newer|  |
| Consul | 1.10.3 or newer | 1.10.3 or newer |
| Vault | 1.8.4 or newer | 1.8.4 or newer |
| Nomad | 1.1.6 or newer | 1.1.6 or newer |

## Requirements

### Required modules
No modules required.

### Required software
- [Consul](https://releases.hashicorp.com/consul/) service available on specified
  port.
- [Vault](https://releases.hashicorp.com/vault/) service available on specified
  port.

## Usage
The following command will run an example with standalone instance of Code
Server.

```text
terraform init
terraform plan
terraform apply
```

### Verifying setup
You can verify that Code Server ran successful by checking the Code
Server UI on [localhost:3000/](https://localhost:3000/).

## Example usage
These are the default values for the Code Server module.

```hcl
module "code_server" {
  source = "../.."

  # nomad
  nomad_datacenters  = ["dc1"]
  nomad_namespace    = "default"
  nomad_host_volume  = "persistence"

  # code-server
  service_name       = "code-server"
  host               = "127.0.0.1"
  port_static        = 3000
  image              = "pmikus/docker-code-server-base:latest"
  volume_destination = "/home/workspace"
  use_host_volume    = true
  use_canary         = true
  use_vault_kms      = false
}
```

## Volumes
We are using
[host volume](https://www.nomadproject.io/docs/job-specification/volume) to
store Code Server data. Code Server data will now be available in the
`/home/workspace` folder.

