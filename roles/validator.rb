name        "validator"
description "Job posting validator"

run_list    "role[base]",
            "recipe[applications]",
            "recipe[applications::validator]"
