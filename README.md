# R509::Cert::Validator

Have an x.509 certificate that you need to validate against its Online
Certificate Status Protocol (OCSP) or Certificate Revocation List (CRL)
endpoint? This gem uses the `r509` library for x.509 processing, and performs
OCSP and CRL processing.

[![Build Status](https://travis-ci.org/bkerley/r509-cert-validator.png?branch=master)](https://travis-ci.org/bkerley/r509-cert-validator)
[![Code Climate](https://codeclimate.com/github/bkerley/r509-cert-validator.png)](https://codeclimate.com/github/bkerley/r509-cert-validator)

## Installation

Add this line to your application's Gemfile:

    gem 'r509-cert-validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install r509-cert-validator

## Usage

```ruby
validator = R509::Cert::Validator.new @socket.peer_cert

# Returns false on invalid certificates
# Raises R509::Cert::Validator::Error when checking failed
validator.validate 

# Raises R509::Cert::Validator::CrlError and
#        R509::Cert::Validator::OcspError on invalid certificates
# Raises R509::Cert::Validator::Error when checking failed
validator.validate!

# OCSP and CRL checking are enabled when present in certificates, but
# can be disabled individually
validator.validate ocsp: false
validator.validate! crl: false

# Attempting to validate OCSP and/or CRL when a cert does not have them raises
# R509::Cert::Validator::Error
validator.validate ocsp: true
```

## Development and Testing

This library requires a bit of Public Key Infrastructure (PKI) for testing.
Fortunately, it's easy to set up.

0. Install dependencies with `bundle install`.
0. Optional: clean out the existing PKI with `rake ca:clean`
1. Generate a CA and testing certificates with `rake ca:all`
2. Start the CRL and OCSP endpoint with `bundle exec ruby spec/support/ca_server.rb`
   and let it run. This command starts a web server on port 22022.
3. Run the specs with `bundle exec rspec`
4. CTRL-C or otherwise kill the CRL and OCSP server when you no longer need it.

This process is automated by `travis.sh`, and you can just run that :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
