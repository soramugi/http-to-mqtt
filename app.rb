require 'bundler'
Bundler.require

set server: 'webrick'
Dotenv.load

def auth?(user, pass)
  (ENV['AUTH_USER'].nil? || user == ENV['AUTH_USER']) && pass == ENV['AUTH_PASS']
end

get '/:path' do
  return status 400 unless auth?(params[:username], params[:path])

  uri = URI.parse ENV['CLOUDMQTT_URL'] || 'mqtt://localhost:1883'
  conn_opts = {
    remote_host: uri.host,
    remote_port: uri.port,
    username: uri.user,
    password: uri.password,
  }
  message = ENV['MQTT_MESSAGE'] || params[:message] || 1
  topic   = ENV['MQTT_TOPIC'] || params[:topic] || 'http'
  MQTT::Client.connect(conn_opts) do |c|
    c.publish(topic, message)
  end
end
