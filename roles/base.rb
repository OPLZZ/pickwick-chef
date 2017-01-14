name        "base"
description "Basic tools and utilities for all nodes"

run_list    "recipe[build-essential]",
            "recipe[curl]",
            "recipe[vim]",
            "recipe[ufw]"

override_attributes(
  monit: {
    http_auth: {
      username: ENV['MONIT_USER'],
      password: ENV['MONIT_PASSWORD']
    },
    alert_email: ENV['MONIT_ALERT_EMAIL'],
    mail: {
      from: ENV['MONIT_FROM_EMAIL'],
      hostname: ENV['MONIT_SMTP_SERVER'],
      port: ENV['MONIT_SMTP_PORT'],
      username: ENV['MONIT_SMTP_USER'],
      password: ENV['MONIT_SMTP_PASSWORD'],
      security: 'TLSV1'
    }
  }
)
