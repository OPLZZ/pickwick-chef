name        "app"
description "Pickwick APP cookbook"

run_list    "role[base]",
            "recipe[applications]",
            "recipe[applications::app]"

