require 'net/http'

module R509
  class Cert
    class Validator
      class BasicValidator
        def initialize(cert, issuer)
          @cert = cert
          @issuer = issuer
        end

        private
        def get(uri)
          resp = Net::HTTP.get_response URI(uri)
          if resp.code != '200'
            raise Error.new("Unexpected HTTP #{resp.code} from OCSP endpoint")
          end

          resp.body
        end
      end
    end
  end
end
