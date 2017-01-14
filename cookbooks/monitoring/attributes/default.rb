default.monit[:http_auth]    = { :username => "monit", :password => "monit" }
default.monit[:poll_period]  = 60
default.monit[:start_delay]  = 60

default.monit[:log]          = '/var/log/monit.log'
default.monit[:pid]          = '/var/run/monit.pid'

message = <<-EOS
[damepraci] #{node.hostname} : $SERVICE $ACTION
$DESCRIPTION
--
http://#{node.monit[:http_auth][:username]}:#{node.monit[:http_auth][:password]}@damepraci.cz:2812/
EOS

default.monit[:mail] = {
  :hostname => "localhost",
  :port     => 25,
  :username => nil,
  :password => nil,
  :from     => "monit@$HOST",
  :subject  => "[monit] [damepraci] $EVENT: $SERVICE at #{node.hostname}",
  :message  => message,
  :security => nil,  # 'SSLV2'|'SSLV3'|'TLSV1'
  :timeout  => 30
}
