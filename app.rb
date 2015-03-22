require 'bundler'
Bundler.require

set server: 'webrick'
Dotenv.load

def auth?(user, pass)
  (ENV['AUTH_USER'].nil? || user == ENV['AUTH_USER']) && pass == ENV['AUTH_PASS']
end

get '/:path' do
  return status 400 unless auth?(params[:username], params[:path])

  message = ENV['MQTT_MESSAGE'] || params[:message] || 1
  topic   = ENV['MQTT_TOPIC'] || params[:topic]
  opt = {
    host: ENV['MQTT_HOST'],
    port: ENV['MQTT_PORT'].nil? ? 1883 : ENV['MQTT_PORT'].to_i,
    username: ENV['MQTT_USERNAME'],
    password: ENV['MQTT_PASSWORD']
  }
  MQTT::Client.connect(opt) do |c|
    c.publish(topic, message)
  end
end
