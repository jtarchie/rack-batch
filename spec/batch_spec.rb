require "spec_helper"
require "rack/test"

describe "adding Rack::Batch as a middleware" do
  include Rack::Test::Methods

  def app
    Class.new(Application) do
      use Rack::Batch
    end
  end

  def batch_responses
    JSON.parse(last_response.body)
  end

  def batch_response
    batch_responses.first
  end

  def json_body
    JSON.parse(response.body)
  end

  def batch_request(ops)
    post '/batch', {}, { 'rack.input' => StringIO.new({ops: ops}.to_json) }
  end

  shared_examples_for "GET default request" do
    it "returns the status OK" do
      response.status.should == 200
    end

    it "returns the body" do
      response.body.should == "pong"
    end

    it "returns the default headers" do
      response.headers.should include({"Content-Type"=>"plain/text", "Content-Length"=>"4"})
    end
  end

  context "handling a GET request" do
    context "with no batch requests" do
      let(:response) { last_response }

      before { get "/ping" }

      it_behaves_like("GET default request")
    end

    context "within a batch request" do
      let(:response) { OpenStruct.new batch_response }

      context "a basic request" do
        before { batch_request [{method: "get", url: "/ping"}] }

        it_behaves_like("GET default request")
      end

      context "with query string and params" do
        let(:status) { 511 }
        let(:name) { "JT" }

        before { batch_request [{method: "get", url: "/ping?status=#{status}", params: {name: name}}] }

        it "returns the status OK" do
          response.status.should == status
        end

        it "returns the body" do
          response.body.should == "pong #{name}"
        end

        it "returns the default headers" do
          response.headers.should include({"Content-Type"=>"plain/text", "Content-Length"=>"#{"pong #{name}".length}"})
        end
      end
    end
  end

  shared_examples_for "POST default request" do
    it "returns the status OK" do
      response.status.should == 201
    end

    it "returns the body" do
      json_body.should == {'name' => 'JT', 'body' => ""}
    end

    it "returns the default headers" do
      response.headers.should include({"Content-Type"=>"application/json;charset=utf-8", "Content-Length"=>"23"})
    end
  end

  context "handling POST requests" do
    context "with no batch requests" do
      let(:response) { last_response }

      before { post "/body" }

      it_behaves_like "POST default request"
    end

    context "within a batch request" do
      context "with a body" do
        let(:response) { OpenStruct.new batch_response }
        let(:body) { "Hello World" }

        before { batch_request [{method: "post", url: "/body", body: body}] }

        it "returns the status 201" do
          response.status.should == 201
        end

        it "returns the body" do
          json_body.should == {'name' => 'JT', 'body' => body}
        end

        it "returns the default headers" do
          response.headers.should include({"Content-Type"=>"application/json;charset=utf-8", "Content-Length"=>"34"})
        end
      end

      context "with headers" do
        let(:response) { OpenStruct.new batch_response }
        let(:headers) do
          {
            'HTTP_USER_AGENT' => 'Awesome Browser',
            'rack.should_be_ignored' => 'Not Included'
          }
        end

        before { batch_request [{method: "post", url: "/headers", headers: headers } ] }

        it "returns the status 201" do
          response.status.should == 201
        end

        it "returns the headers passed" do
          json_body["headers"]['HTTP_USER_AGENT'].should == 'Awesome Browser'
        end

        it "removes headers with 'rack' prepended" do
          json_body["headers"]['rack.should_be_ignored'].should be_nil
        end
      end
    end
  end

  context "handling multiple requests" do
    context "for GET request" do
      before do
        batch_request [{method: "get", url: "/ping"}] * 5
      end

      it "returns the correct amount of responses" do
        batch_responses.length.should == 5
      end
    end
  end

  context "with customizations" do
    context "on an endpoint" do
      def app
        Class.new(Application) do
          use Rack::Batch, endpoint: "other_batch_point"
        end
      end

      it "cannot get anything from the default endpoint" do
        post '/batch'
        last_response.status.should == 404
      end

      it "only loads from the specified batch end point" do
        post '/other_batch_point'
        last_response.status.should == 200
      end
    end

    context "don't double encode JSON body" do
      let(:response) { OpenStruct.new(batch_response) }
      def app
        Class.new(Application) do
          use Rack::Batch, encode_json: false
        end
      end

      context "when response body is JSON" do
        it "doesn't encode JSON into JSON string" do
          batch_request [{method: "post", url:"/headers"}]

          response.body['headers']['REQUEST_METHOD'].should == "POST"
          response.body['headers']['PATH_INFO'].should == "/headers"
        end
      end
    end

    context "with max limit of batch requests" do
      def app
        Class.new(Application) do
          use Rack::Batch, limit: 3
        end
      end

      it "returns no more than limit requests" do
        batch_request [{method: "get", url: "/ping"}] * 5
        batch_responses.length.should == 3
      end
    end
  end
end