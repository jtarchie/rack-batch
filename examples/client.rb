require 'rest-client'
require 'json'
require 'ap'

response = RestClient.post 'http://127.0.0.1:4567/batch', {
    ops: [
      {method: "get", url: "/time"},
      {method: "get", url: "/time.json"}
    ]
}.to_json, content_type: :json

puts "Response body"
ap JSON.parse(response.body)