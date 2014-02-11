require 'net/http'

module R509
  class Cert
    class Validator
      class BasicValidator
        def initializer(cert, issuer)
          @cert = cert
          @issuer = issuer
        end

        private
        def get(url)
          resp = Net::HTTP.get_response uri
          if resp.code != '200'
            raise Error.new("Unexpected HTTP #{resp.code} from OCSP endpoint")
          end

          resp.body
        end
      end
    end
  end
end
