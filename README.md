# Rack::Batch

This gem allows multiple requests to be batch into a single request. This can be handy when doing API calls from mobile devices with a slow connection.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-batch', require: "rack/batch"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-batch

    ...

    require "rack/batch"

## Usage

In a Rack `config.ru` file somewhere:

```ruby
use Rack::Batch, {endpoint: '/secret_batch', limit: 10}

run MyRackApp
```

Now when a user POSTs `/secret_batch` endpoint then can make a request with multiple requests (no more than 10). All requests are passed through the `ops` param.

## Example

Please look at the `examples/` folder for usage.

## Options

`Rack::Batch` can take several options as a hash argument.

* *endpoint*
* *limit*
* *encode_json*

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
