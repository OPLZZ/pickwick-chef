name        "base"
description "Basic tools and utilities for all nodes"

run_list    "recipe[build-essential]",
            "recipe[curl]",
            "recipe[vim]"

override_attributes(
  monit: {
    http_auth: {
      username: ENV['MONIT_USER'],
      password: ENV['MONIT_PASSWORD']
    }
  }
)
