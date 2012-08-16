# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack/batch/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["JT Archie", "Alex Koppel"]
  gem.email         = ["jtarchie@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-batch"
  gem.require_paths = ["lib"]
  gem.version       = Rack::Batch::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "sinatra"
  gem.add_development_dependency "awesome_print"
end
