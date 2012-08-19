require "rack/batch/version"
require "json"

module Rack
  class Batch
    def initialize(app, options = {})
      @endpoint = "/#{options[:endpoint] || "batch"}".gsub(/^\/\//,'/')
      @limit = options[:limit] || 0
      @double_encode_json = options[:encode_json] == false
      @app = app
    end

    def call(env)
      return @app.call(env) unless env['PATH_INFO'] == @endpoint && env['REQUEST_METHOD'] == "POST"

      json = JSON.parse(env['rack.input'].read) rescue {}
      internal_requests = (json['ops'] || [])[0..@limit-1]

      internal_requests = internal_requests.map do |op|
        internal_response(env, op)
      end

      [ 200, {}, JSON.generate(internal_requests) ]
    end

    private

    def internal_response(env, op)
      status, headers, body = @app.call(new_env_from_op(env, op))
      internal_response = {
          status: status,
          headers: headers,
          body: body.join
      }
      if @double_encode_json && headers['Content-Type'].include?("application/json")
        internal_response[:body] = JSON.parse(internal_response[:body])
      end
      internal_response
    end

    def new_env_from_op(env, op)
      path, query_string = op['url'].split '?'

      op_env = env.dup.merge(
          'REQUEST_METHOD' => op['method'].upcase,
          'PATH_INFO' => path
      )

      add_headers(op, op_env)
      add_get_params(op, op_env, query_string)

      op_env['rack.input'] = StringIO.new(op['body']) unless op['body'].nil?
      op_env
    end

    def add_headers(op, op_env)
      op['headers'] ||= {}


      op['headers'].reject{|k,v| k =~ /^rack/i}.each do |name, value|
        op_env["HTTP_#{name.gsub("-", "_").upcase}"] = value
        op_env[name] = value
      end
    end

    def add_get_params(op, op_env, query_string)
      qs_params = URI.decode_www_form(query_string || "")
      params = op['params'] || []

      op_env['QUERY_STRING'] = URI.encode_www_form(qs_params + params.to_a)
      op_env
    end
  end
end