name        "whole_stack"
description "Whole Damepraci stack on one EC2 server"

run_list    "role[elasticsearch]",
            "recipe[elasticsearch::data]",
            "role[api]",
            "role[workers]",
            "role[app]"

override_attributes(
  firewall: {
    rules: [
      { http: { port: 80 } },
      { https: { port: 443 } },
      { monit: { port: 2812 } },
      { elasticsearch: { port: 8080 } }
    ]
  },
  redisio: {
    version: "2.8.23"
  },
  elasticsearch: {
    allocated_memory: "512m",
    plugins: {
      "karmi/elasticsearch-paramedic" => {} 
    },
    path: {
      data: "/usr/local/var/data/elasticsearch/disk1"
    },
    data: {
      devices: {
        :"/dev/disk/by-id/scsi-0DO_Volume_damepraci" => {
          file_system:      "ext4",
          mount_options:    "rw,user",
          mount_path:       "/usr/local/var/data/elasticsearch/disk1",
          format_command:   "mkfs.ext4 -F",
          fs_check_command: "dumpe2fs"
        }
      }
    }
  },
  applications: {
    api: {
      url: "api.damepraci.cz",
      elasticsearch: {
        ip: "127.0.0.1"
      },
      sidekiq: {
        ip: "127.0.0.1"
      }
    },
    app: {
      url: "damepraci.cz"
    },
    validator: {
      url: "validator.damepraci.cz",
      fuseki: {
        version: "1.1.1"
      }
    },
    workers: {
      url: "workers.damepraci.cz"
    }
  }
)
