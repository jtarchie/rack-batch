# Rack::Batch

This gem allows multiple requests to be batch into a single request. This can be handy when doing API calls from mobile devices with a slow connection.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-batch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-batch

## Usage

In a Rack `config.ru` file somewhere:

    use Rack::Batch

    run MyRackApp

Now when a user hits `/batch` endpoint then can make a request with multiple requests.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
