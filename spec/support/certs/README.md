**DO NOT USE THESE IN PRODUCTION**

This directory has certificates and a key for testing Riak authentication.

* no_validator.crt - a certificate with no CRL or OCSP data
* ca.crt - a certificate for the CA that issued no_validator.crt
* github_chain.crt - the complete set of certificates presented by
  https://github.com at 6:48 PM US Eastern time on Feb. 6, 2014. This
  certificate has CRL and OCSP endpoints.
* github.crt - the GitHub certificate from above
* digicert_ev.crt - the Digicert EV CA that issued github.crt

**DO NOT USE THESE IN PRODUCTION**

These were generated using https://github.com/basho-labs/riak-ruby-ca .
