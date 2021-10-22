<!-- markdownlint-disable MD041 -->

# Terraform-nomad-openvscode-server
Terraform-nomad-miopenvscode-servernio module is IaaC - infrastructure as a
code. Module contains a nomad job with [OpenVSCode](https://www.gitpod.io).
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
The following command will run an example with standalone instance of OpenVSCode
Server.

```text
terraform init
terraform plan
terraform apply
```

### Verifying setup
You can verify that OpenVSCode Server ran successful by checking the OpenVSCode
Server UI on [localhost:3000/](http://localhost:3000/).

## Example usage
These are the default values for the OpenVSCode Server module.

```hcl
module "openvscode" {
  source = "../.."

  # nomad
  nomad_datacenters  = ["dc1"]
  nomad_namespace    = "default"
  nomad_host_volume  = "persistence"

  # openvscode
  service_name       = "openvscode"
  host               = "127.0.0.1"
  port_static        = 3000
  image              = "gitpod/openvscode-server"
  volume_destination = "/home/workspace"
  use_host_volume    = true
  use_canary         = true
  use_vault_kms      = false
}
```

## Volumes
We are using
[host volume](https://www.nomadproject.io/docs/job-specification/volume) to
store OpenVSCode data. OpenVSCode data will now be available in the
`persistence/OpenVSCode` folder.
