name        "workers"
description "Pickwick workers cookbook"

run_list    "role[base]",
            "role[sidekiq-redis]",
            "recipe[applications]",
            "recipe[applications::workers]"

override_attributes(
  applications: {
    workers: {
      sidekiq: {
        ip:       "127.0.0.1",
        username: ENV["SIDEKIQ_USERNAME"],
        password: ENV["SIDEKIQ_PASSWORD"]
      }
    }
  }
)
