name        "sidekiq-redis"
description "Pickwick sidekiq redis cookbook"

run_list    "role[base]",
            "recipe[redisio::install]",
            "recipe[redisio::enable]",
            "recipe[monitoring]",
            "recipe[monitoring::redis]"
