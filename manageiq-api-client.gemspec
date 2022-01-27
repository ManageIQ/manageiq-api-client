# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'manageiq/api/client/version'

Gem::Specification.new do |spec|
  spec.name          = "manageiq-api-client"
  spec.version       = ManageIQ::API::Client::VERSION
  spec.authors       = ["Alberto Bellotti", "Jason Frey"]
  spec.email         = ["abellott@redhat.com", "jfrey@redhat.com"]

  spec.summary       = "ManageIQ API Client"
  spec.description   = %q{
    This gem provides Ruby access to the ManageIQ API by exposing the ManageIQ
    collections, resources and related actions as Ruby objects and equivalent methods.
  }
  spec.homepage      = "http://github.com/ManageIQ/manageiq-api-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files        += %w(README.md LICENSE.txt)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "manageiq-style"
  spec.add_development_dependency "rake",          ">= 12.3.3"
  spec.add_development_dependency "rspec",         "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"

  spec.add_dependency "activesupport", ">= 5.0", "< 7.0"
  spec.add_dependency "faraday", "~> 1.0.0"
  spec.add_dependency "faraday_middleware", "~> 1.0"
  spec.add_dependency "json", "~> 2.3"
  spec.add_dependency "more_core_extensions"
  spec.add_dependency "query_relation"
end
