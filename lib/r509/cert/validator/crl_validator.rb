module R509
  class Cert
    class Validator
      class CrlValidator < BasicValidator
        def available?
          return false unless cdp
          return false if uris.empty?
          return true
        end

        def validate!
          unless available?
            raise Error.new "Tried to validate CRL but cert has no CRL data"
          end

          body = R509::CRL::SignedList.new(get(uris.first))

          unless body.verify @issuer.public_key
            raise CrlError.new "CRL did not match certificate"
          end

          if body.revoked? @cert.serial
            raise CrlError.new "CRL listed certificate as revoked"
          end

          return true
        end

        private
        def cdp
          @cert.crl_distribution_points
        end

        def uris
          cdp.uris
        end
      end
    end
  end
end
