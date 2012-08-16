require 'sinatra/base'
require 'json'

class Application < Sinatra::Base
  get '/ping' do
    status = params[:status] ? params[:status].to_i : 200
    body = "pong"
    body += " #{params[:name]}" if params[:name]

    [status, body]
  end

  post '/body' do
    [201, {name: 'JT', body: request.body.read.to_s}.to_json]
  end

  post '/headers' do
    [201, {headers: request.env}.to_json]
  end
end