# R509::Cert::Validator

Have an x.509 certificate that you need to validate against its Online
Certificate Status Protocol (OCSP) or Certificate Revocation List (CRL)
endpoint? This gem uses the `r509` library for x.509 processing, and performs
OCSP and CRL processing.

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
