name        "whole_stack"
description "Whole Damepraci stack on one EC2 server"

run_list    "role[elasticsearch]",
            "recipe[elasticsearch::aws]",
            "recipe[elasticsearch::ebs]",
            "recipe[elasticsearch::data]",
            "role[api]",
            "role[workers]",
            "role[validator]",
            "role[app]"

override_attributes(
  elasticsearch: {
    allocated_memory: "2048m",
    discovery: {
      type: "ec2"
    },
    cloud: {
      aws: {
        access_key: ENV["AWS_ACCESS_KEY_ID"],
        secret_key: ENV["AWS_SECRET_ACCESS_KEY"],
        region:     ENV["AWS_REGION"]
      },
      ec2: {
        security_group: "elasticsearch"
      }
    },
    plugins: {
      "elasticsearch/elasticsearch-cloud-aws" => { "version" => "2.0.0" },
      "karmi/elasticsearch-paramedic"         => {} 
    },
    path: {
      data: "/usr/local/var/data/elasticsearch/disk1"
    },
    data: {
      devices: {
        :"/dev/xvdb" => {
          file_system:      "ext3",
          mount_options:    "rw,user",
          mount_path:       "/usr/local/var/data/elasticsearch/disk1",
          format_command:   "mkfs.ext3",
          fs_check_command: "dumpe2fs",
          ebs: {
            device:               '/dev/sda2',
            size:                  20,
            delete_on_termination: false,
            type:                  "gp2"
          }
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
