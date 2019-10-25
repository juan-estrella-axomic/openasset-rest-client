# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Version/version.rb'

Gem::Specification.new do |spec|
  spec.name          = "openasset-rest-client"
  spec.version       = Openasset::VERSION
  spec.authors       = ["Juan Estrella"]
  spec.email         = ["juan.estrella@columbia.edu"]

  spec.summary       = %q{This gem will enable easy interaction with OpenAsset using the REST API.}

  spec.description   = "This client allows users to programmatically create, update, retrieve and delete " +
  						          "objects in openasset through the REST API."
  spec.homepage      = "https://github.com/juan-estrella-axomic/openasset"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "certified", "~> 1.0"
  spec.add_dependency "mime-types", "~> 3.1"
  spec.add_dependency "ruby-progressbar", "~> 1.8"
  spec.add_dependency "colorize", "~> 0.8"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
