# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'r509/cert/validator/version'

Gem::Specification.new do |spec|
  spec.name          = "r509-cert-validator"
  spec.version       = R509::Cert::Validator::VERSION
  spec.authors       = ["Bryce Kerley"]
  spec.email         = ["bkerley@brycekerley.net"]
  spec.description   = %q{Tool for validating x509 certificates against CRLs and OCSP.}
  spec.summary       = %q{An r509-based tool for validating x509 certificates against CRLs and OCSP.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1.1"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency 'rack', '~> 1.5.2'
  spec.add_development_dependency 'puma', '~> 2.7.1'
  spec.add_development_dependency 'r509-ocsp-responder', '~> 0.3.3'
  spec.add_development_dependency 'r509-validity-crl', '~> 0.1.1'
  spec.add_runtime_dependency "r509", "~> 0.10.0"
end
