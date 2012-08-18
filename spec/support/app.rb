require 'sinatra/base'
require 'json'

class Application < Sinatra::Base
  get '/ping' do
    content_type "plain/text"
    status = params[:status] ? params[:status].to_i : 200
    body = "pong"
    body += " #{params[:name]}" if params[:name]

    [status, body]
  end

  post '/body' do
    content_type "application/json"
    [201, {name: 'JT', body: request.body.read.to_s}.to_json]
  end

  post '/headers' do
    content_type "application/json"
    [201, {headers: request.env}.to_json]
  end
end