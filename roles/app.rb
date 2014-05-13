name        "app"
description "Pickwick APP cookbook"

run_list    "role[base]",
            "recipe[applications]",
            "recipe[applications::app]"

override_attributes(
  applications: {
    app: {
      api: {
        url:      ENV["PICKWICK_API_URL"],
        token:    ENV["PICKWICK_API_TOKEN"]
      },
      admin: {
        username: ENV["PICKWICK_ADMIN_USERNAME"],
        password: ENV["PICKWICK_ADMIN_PASSWORD"]
      }
    }
  }
)
