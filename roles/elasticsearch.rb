name        "elasticsearch"
  description "Configuration for elasticsearch nodes"

run_list    "role[base]",
            "recipe[nginx]",
            "recipe[java]",
            "recipe[elasticsearch]",
            "recipe[elasticsearch::plugins]",
            "recipe[elasticsearch::proxy]",
            "recipe[monitoring]",
            "recipe[monitoring::nginx]",
            "recipe[monitoring::elasticsearch]"

attributes = {
  java: {
    install_flavor: "openjdk",
    jdk_version:    "7"
  },
  elasticsearch: {
    version:      "1.0.0.RC1",
    cluster_name: "pickwick-api",
    plugins:      { "karmi/elasticsearch-paramedic" => {} },
    nginx: {
      users: [{ username: ENV["NGINX_USER"], password: ENV["NGINX_PASSWORD"] }],
      allow_cluster_api: true
    }
  }
}

if ENV["PROVIDER"] == "AMAZON"
  attributes[:elasticsearch][:discovery] = { type: "ec2" }
  attributes[:elasticsearch][:cloud]     = { aws: { access_key: ENV["AWS_ACCESS_KEY_ID"], secret_key: ENV["AWS_SECRET_ACCESS_KEY"] },
                                             ec2: { security_group: "elasticsearch" }}
end

override_attributes attributes
