name        "workers"
description "Pickwick workers cookbook"

run_list    "role[base]",
            "role[sidekiq-redis]",
            "recipe[applications]",
            "recipe[applications::workers]"

override_attributes(
  applications: {
    workers: {
      api: {
        url:   ENV["PICKWICK_API_URL"],
        token: ENV["PICKWICK_API_RW_TOKEN"]
      },
      sidekiq: {
        ip:       "127.0.0.1",
        username: ENV["SIDEKIQ_USERNAME"],
        password: ENV["SIDEKIQ_PASSWORD"]
      }
    }
  }
)
