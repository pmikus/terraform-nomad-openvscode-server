job "${job_name}" {
  # The "region" parameter specifies the region in which to execute the job.
  # If omitted, this inherits the default region name of "global".
  # region    = "${region}"

  # The "datacenters" parameter specifies the list of datacenters which should
  # be considered when placing this task. This must be provided.
  datacenters = "${datacenters}"

  # The "type" parameter controls the type of job, which impacts the scheduler's
  # decision on placement. This configuration is optional and defaults to
  # "service". For a full list of job types and their differences, please see
  # the online documentation.
  #
  #     https://www.nomadproject.io/docs/jobspec/schedulers
  #
  type        = "service"

  update {
    # The "max_parallel" parameter specifies the maximum number of updates to
    # perform in parallel. In this case, this specifies to update a single task
    # at a time.
    max_parallel      = ${max_parallel}

    health_check      = "checks"

    # The "min_healthy_time" parameter specifies the minimum time the allocation
    # must be in the healthy state before it is marked as healthy and unblocks
    # further allocations from being updated.
    min_healthy_time  = "10s"

    # The "healthy_deadline" parameter specifies the deadline in which the
    # allocation must be marked as healthy after which the allocation is
    # automatically transitioned to unhealthy. Transitioning to unhealthy will
    # fail the deployment and potentially roll back the job if "auto_revert" is
    # set to true.
    healthy_deadline  = "3m"

    # The "progress_deadline" parameter specifies the deadline in which an
    # allocation must be marked as healthy. The deadline begins when the first
    # allocation for the deployment is created and is reset whenever an allocation
    # as part of the deployment transitions to a healthy state. If no allocation
    # transitions to the healthy state before the progress deadline, the
    # deployment is marked as failed.
    progress_deadline = "10m"

%{ if use_canary }
    # The "canary" parameter specifies that changes to the job that would result
    # in destructive updates should create the specified number of canaries
    # without stopping any previous allocations. Once the operator determines the
    # canaries are healthy, they can be promoted which unblocks a rolling update
    # of the remaining allocations at a rate of "max_parallel".
    #
    # Further, setting "canary" equal to the count of the task group allows
    # blue/green deployments. When the job is updated, a full set of the new
    # version is deployed and upon promotion the old version is stopped.
    canary            = ${canary}

    # Specifies if the job should auto-promote to the canary version when all
    # canaries become healthy during a deployment. Defaults to false which means
    # canaries must be manually updated with the nomad deployment promote
    # command.
    auto_promote      = ${auto_promote}

    # The "auto_revert" parameter specifies if the job should auto-revert to the
    # last stable job on deployment failure. A job is marked as stable if all the
    # allocations as part of its deployment were marked healthy.
    auto_revert       = ${auto_revert}
%{ endif }
  }

  # All groups in this job should be scheduled on different hosts.
  constraint {
    operator = "distinct_hosts"
    value    = "true"
  }

  # The "group" stanza defines a series of tasks that should be co-located on
  # the same Nomad client. Any task within a group will be placed on the same
  # client.
  #
  #     https://www.nomadproject.io/docs/job-specification/group
  #
  group "${job_name}-group-1" {
    # The "count" parameter specifies the number of the task groups that should
    # be running under this group. This value must be non-negative and defaults
    # to 1.
    count = ${group_count}

    # The volume stanza allows the group to specify that it requires a given
    # volume from the cluster. The key of the stanza is the name of the volume
    # as it will be exposed to task configuration.
    #
    # https://www.nomadproject.io/docs/job-specification/volume
    %{ if use_host_volume }
    volume "${job_name}-volume-1" {
      type      = "host"
      read_only = false
      source    = "${volume_source}"
    }
    %{ endif }

    # The restart stanza configures a tasks's behavior on task failure. Restarts
    # happen on the client that is running the task.
    #
    # https://www.nomadproject.io/docs/job-specification/restart
    #
    restart {
      interval = "30m"
      attempts = 40
      delay    = "15s"
      mode     = "delay"
    }

    # The "task" stanza creates an individual unit of work, such as a Docker
    # container, web application, or batch processing.
    #
    #     https://www.nomadproject.io/docs/job-specification/task.html
    #
    task "${job_name}-task-1" {
      # The "driver" parameter specifies the task driver that should be used to
      # run the task.
      driver = "docker"

    %{ if use_host_volume }
      volume_mount {
        volume      = "${job_name}-volume-1"
        destination = "${volume_destination}"
        read_only   = false
      }
    %{ endif }

    %{ if use_vault_provider }
      vault {
        policies = "${vault_kv_policy_name}"
      }
    %{ endif }

      # The "config" stanza specifies the driver configuration, which is passed
      # directly to the driver to start the task. The details of configurations
      # are specific to each driver, so please see specific driver
      # documentation for more information.
      config {
        image       = "${image}"
        dns_servers = [
          "172.17.0.1"
        ]
        port_map {
          https     = ${port_static}
        }
        privileged  = false
        volumes     = [
          "secrets/config.yaml:/home/coder/.config/code-server/config.yaml",
          "secrets/settings.json:/home/coder/.local/share/code-server/User/settings.json",
          "secrets/rclone.json:/tmp/rclone-tasks.json"
        ]
      }

      # The env stanza configures a list of environment variables to populate
      # the task's environment before starting.
      env {
        ${ envs }
      }

      # The service stanza instructs Nomad to register a service with Consul.
      #
      #     https://www.nomadproject.io/docs/job-specification/service
      #
      service {
        name = "${service_name}"
        port = "https"
        tags = [ "${service_name}$${NOMAD_ALLOC_INDEX}" ]
      }

      # The "template" stanza instructs Nomad to manage a template, such as
      # a configuration file or script. This template can optionally pull data
      # from Consul or Vault to populate runtime configuration data.
      #
      # For more information and examples on the "template" stanza, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/template
      #
      template {
        change_mode   = "noop"
        change_signal = "SIGINT"
        destination   = "secrets/config.yaml"
        data          = <<EOH
auth: password
password: ${password}
cert: ${cert}
EOH
      }
      
      template {
        change_mode   = "noop"
        change_signal = "SIGINT"
        destination   = "secrets/settings.json"
        data          = <<EOH
{
    "workbench.colorTheme": "SynthWave '84",
    "workbench.iconTheme": "vs-minimal",
    "editor.fontSize": 12,
    "files.autoSave": "off",
    "files.trimTrailingWhitespace": true,
    "workbench.startupEditor": "none",
    "gitlens.codeLens.enabled": false,
    "editor.minimap.enabled": false,
    "editor.rulers": [
        80
    ],
    "sync.gist": "d23b346a1979446aac26dece5c983386",
    "sync.autoDownload": true,
    "sync.autoUpload": true
}
EOH
      }
      
      template {
        change_mode   = "noop"
        change_signal = "SIGINT"
        destination   = "secrets/rclone.json"
        data          = <<EOH
{
    "version": "2.0.0",
    "tasks": [
      {
        "label": "push_remote",
        "type": "shell",
        "command": "sh /home/coder/push_remote.sh",
        "presentation": {
          "reveal": "always"
        },
        "problemMatcher": [],
        "options": {
          "statusbar": {
            "label": "$(repo-push) rclone: push"
          }
        }
      },
      {
        "label": "pull_remote",
        "type": "shell",
        "command": "sh /home/coder/pull_remote.sh",
        "presentation": {
          "reveal": "always"
        },
        "problemMatcher": [],
        "options": {
          "statusbar": {
            "label": "$(repo-pull) rclone: pull"
          }
        }
      }
    ]
}
EOH
      }

      # The "resources" stanza describes the requirements a task needs to
      # execute. Resource requirements include memory, network, cpu, and more.
      # This ensures the task will execute on a machine that contains enough
      # resource capacity.
      #
      #     https://www.nomadproject.io/docs/job-specification/resources
      #
      resources {
        cpu        = ${cpu}
        memory     = ${memory}
        # The network stanza specifies the networking requirements for the task
        # group, including the network mode and port allocations. When
        # scheduling jobs in Nomad they are provisioned across your fleet of
        # machines along with other jobs and services. Because you don't know in
        # advance what host your job will be provisioned on, Nomad will provide
        # your tasks with network configuration when they start up.
        #
        #     https://www.nomadproject.io/docs/job-specification/network
        #
        network {
          port "https" {
            static = ${port_static}
          }
        }
      }
    }
  }
}
