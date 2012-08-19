require 'sinatra'
require 'rack/batch'
require 'json'
require 'ap'

class Application < Sinatra::Base
  use Rack::Batch

  get '/time' do
    Time.now.to_s
  end

  get '/time.json' do
    content_type "application/json"
    {:current => Time.now}.to_json
  end

  run! if app_file == $0
end

