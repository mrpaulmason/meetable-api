require 'rufus/scheduler'
scheduler = Rufus::Scheduler.new

if Rails.env.production?
  scheduler.every '10m' do
     require "net/http"
     require "uri"
     Net::HTTP.get_response(URI.parse(ENV["WEB_PING"]))
     Net::HTTP.get_response(URI.parse(ENV["API_PING"]))
  end
end