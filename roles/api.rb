name        "api"
description "Pickwick API cookbook"

run_list    "role[elasticsearch]",
            "recipe[applications]",
            "recipe[applications::api]"

attributes = {}

if ENV["PROVIDER"] == "PVE"
  attributes[:applications] = { api: { elasticsearch: {}, sidekiq: {} } }
  attributes[:applications][:api][:elasticsearch][:ip] = "127.0.0.1"
  attributes[:applications][:api][:sidekiq][:ip]       = "127.0.0.1"
end

override_attributes attributes
