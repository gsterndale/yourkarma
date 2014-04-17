# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'what_karma/version'

Gem::Specification.new do |spec|
  spec.name          = "what_karma"
  spec.version       = WhatKarma::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Greg Sterndale"]
  spec.email         = ["gsterndale@gmail.com"]
  spec.summary       = %q{Karma hotspot status client & CLI}
  spec.description   = %q{Determine connectivity, battery and connection speed for your device.}
  spec.homepage      = "http://github.com/gsterndale/what_karma"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",    "~> 2.1"
  spec.add_development_dependency "webmock",  "~> 1.15"
  spec.add_development_dependency "vcr",      "~> 2.6"

  # Release every merge to master as a prerelease
  spec.version = "#{spec.version}.pre#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
end
